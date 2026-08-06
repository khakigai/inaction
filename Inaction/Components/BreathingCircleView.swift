import SwiftUI

struct BreathingCircleView: View {
    @State private var isExpanded = false
    var size: CGFloat = 200

    var body: some View {
        Circle()
            .stroke(
                Color(hex: "39d353").opacity(isExpanded ? 0.38 : 0.25),
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
            .scaleEffect(isExpanded ? 1.18 : 0.82)
            .shadow(color: Color(hex: "39d353").opacity(isExpanded ? 0.09 : 0.03),
                    radius: isExpanded ? 60 : 30)
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    isExpanded = true
                }
            }
    }
}
