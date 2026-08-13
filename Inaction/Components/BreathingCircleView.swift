import SwiftUI

struct BreathingCircleView: View {
    // 0: inhale(expand), 1: hold(expanded), 2: exhale(shrink), 3: hold(shrunk)
    @Binding var phase: Int
    @State private var scale: CGFloat = 0.6
    var size: CGFloat = 200

    private let expandedScale: CGFloat = 1.18
    private let shrunkScale: CGFloat = 0.6
    private let phaseDuration: Double = 4.0

    var body: some View {
        Circle()
            .stroke(
                Color(hex: "39d353").opacity(scale > 1.0 ? 0.38 : 0.25),
                lineWidth: 1.5
            )
            .background(
                Circle().fill(
                    RadialGradient(
                        colors: [Color(hex: "39d353").opacity(0.06), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
            )
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .shadow(color: Color(hex: "39d353").opacity(scale > 1.0 ? 0.09 : 0.03),
                    radius: scale > 1.0 ? 60 : 30)
            .onAppear { startCycle() }
    }

    private func startCycle() {
        advancePhase(0)
    }

    private func advancePhase(_ p: Int) {
        phase = p
        switch p {
        case 0: // Inhale — expand over 4s
            withAnimation(.easeInOut(duration: phaseDuration)) { scale = expandedScale }
        case 1: // Hold expanded — stay for 4s
            break
        case 2: // Exhale — shrink over 4s
            withAnimation(.easeInOut(duration: phaseDuration)) { scale = shrunkScale }
        case 3: // Hold shrunk — stay for 4s
            break
        default:
            break
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + phaseDuration) {
            advancePhase((p + 1) % 4)
        }
    }
}
