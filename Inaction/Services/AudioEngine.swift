import AVFoundation
import Observation

@Observable
final class AudioEngine {
    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var masterGain: Float = 0
    private var gainTarget: Float = 0
    private var isRunning = false

    private var brownState: (Float, Float) = (0, 0)
    private var lpState: (Float, Float) = (0, 0)

    func startBrownNoise() {
        guard !isRunning else { return }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)

        let engine = AVAudioEngine()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let sampleRate = format.sampleRate

        brownState = (0, 0)
        lpState = (0, 0)
        masterGain = 0
        gainTarget = 1

        // Low-pass filter coefficient (~200Hz cutoff for smoothed brown noise)
        let cutoff: Float = 200.0
        let rc: Float = 1.0 / (2.0 * .pi * cutoff)
        let dt: Float = 1.0 / Float(sampleRate)
        let alpha: Float = dt / (rc + dt)
        let volume: Float = 0.6

        let sourceNode = AVAudioSourceNode(format: format) { [self] _, _, frameCount, bufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(bufferList)
            let leftBuf = ablPointer[0].mData!.assumingMemoryBound(to: Float.self)
            let rightBuf = ablPointer[1].mData!.assumingMemoryBound(to: Float.self)

            let leaky: Float = 0.999
            let step: Float = 0.08

            for i in 0..<Int(frameCount) {
                let rampSpeed: Float = 1.0 / Float(sampleRate * 2)
                if self.masterGain < self.gainTarget {
                    self.masterGain = min(self.masterGain + rampSpeed, self.gainTarget)
                } else if self.masterGain > self.gainTarget {
                    self.masterGain = max(self.masterGain - rampSpeed * 4, self.gainTarget)
                }

                let whiteL = Float.random(in: -1...1)
                let whiteR = Float.random(in: -1...1)
                self.brownState.0 = self.brownState.0 * leaky + whiteL * step
                self.brownState.1 = self.brownState.1 * leaky + whiteR * step

                // Single-pole low-pass filter for smoothing
                self.lpState.0 += alpha * (self.brownState.0 - self.lpState.0)
                self.lpState.1 += alpha * (self.brownState.1 - self.lpState.1)

                leftBuf[i] = self.lpState.0 * volume * self.masterGain
                rightBuf[i] = self.lpState.1 * volume * self.masterGain
            }
            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        try? engine.start()

        self.engine = engine
        self.sourceNode = sourceNode
        self.isRunning = true
    }

    func stopBrownNoise() {
        gainTarget = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.engine?.stop()
            if let node = self?.sourceNode { self?.engine?.detach(node) }
            self?.engine = nil
            self?.sourceNode = nil
            self?.isRunning = false
        }
    }

    func playChime() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)

        let chimeEngine = AVAudioEngine()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let sampleRate = format.sampleRate
        let freqs: [Double] = [528, 660, 792]
        let stagger = 0.15
        let duration = 3.0
        let totalSamples = Int(sampleRate * duration)

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalSamples))!
        buffer.frameLength = AVAudioFrameCount(totalSamples)
        let data = buffer.floatChannelData![0]

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            var sample: Float = 0
            for (fi, freq) in freqs.enumerated() {
                let offset = Double(fi) * stagger
                guard t >= offset else { continue }
                let local = t - offset
                let attack: Float = local < 0.05 ? Float(local / 0.05) : 1
                let decay: Float = Float(exp(-local * 1.8))
                sample += Float(sin(freq * .pi * 2 * local)) * 0.15 * attack * decay
            }
            data[i] = sample
        }

        let player = AVAudioPlayerNode()
        chimeEngine.attach(player)
        chimeEngine.connect(player, to: chimeEngine.mainMixerNode, format: format)
        try? chimeEngine.start()
        player.scheduleBuffer(buffer) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                chimeEngine.stop()
            }
        }
        player.play()
    }
}
