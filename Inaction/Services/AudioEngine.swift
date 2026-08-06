import AVFoundation
import Observation

@Observable
final class AudioEngine {
    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var masterGain: Float = 0
    private var gainTarget: Float = 0
    private var isRunning = false

    private var phases: [Double] = [0, 0, 0, 0] // left, right, harmonic1, harmonic2

    func startBinauralBeats() {
        guard !isRunning else { return }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)

        let engine = AVAudioEngine()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let sampleRate = format.sampleRate

        let baseFreq = 180.0
        let beatFreq = 10.0
        let harmonicGain: Float = 0.02
        let binauralGain: Float = 0.12

        phases = [0, 0, 0, 0]
        masterGain = 0
        gainTarget = 1

        let sourceNode = AVAudioSourceNode(format: format) { [self] _, _, frameCount, bufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(bufferList)
            let leftBuf = ablPointer[0].mData!.assumingMemoryBound(to: Float.self)
            let rightBuf = ablPointer[1].mData!.assumingMemoryBound(to: Float.self)

            let phaseInc0 = baseFreq / sampleRate
            let phaseInc1 = (baseFreq + beatFreq) / sampleRate
            let phaseInc2 = (baseFreq * 2) / sampleRate
            let phaseInc3 = (baseFreq * 3) / sampleRate

            for i in 0..<Int(frameCount) {
                let rampSpeed: Float = 1.0 / Float(sampleRate * 2)
                if self.masterGain < self.gainTarget {
                    self.masterGain = min(self.masterGain + rampSpeed, self.gainTarget)
                } else if self.masterGain > self.gainTarget {
                    self.masterGain = max(self.masterGain - rampSpeed * 4, self.gainTarget)
                }

                let left = Float(sin(self.phases[0] * .pi * 2)) * binauralGain
                let right = Float(sin(self.phases[1] * .pi * 2)) * binauralGain
                let h1 = Float(sin(self.phases[2] * .pi * 2)) * harmonicGain
                let h2 = Float(sin(self.phases[3] * .pi * 2)) * harmonicGain

                leftBuf[i] = (left + h1 + h2) * self.masterGain
                rightBuf[i] = (right + h1 + h2) * self.masterGain

                self.phases[0] += phaseInc0
                self.phases[1] += phaseInc1
                self.phases[2] += phaseInc2
                self.phases[3] += phaseInc3
                for j in 0..<4 { if self.phases[j] > 1 { self.phases[j] -= 1 } }
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

    func stopBinauralBeats() {
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
