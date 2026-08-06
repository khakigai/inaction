import SwiftUI

struct CompleteView: View {
    @Environment(NavigationState.self) private var nav

    @State private var showNotification = false

    private var level: Int {
        durationLevel(nav.lastCompletedDuration)
    }

    private var minutes: Int {
        nav.lastCompletedDuration / 60
    }

    var body: some View {
        ZStack {
            DT.cream.ignoresSafeArea()

            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Text("Grass planted")
                        .font(DT.playfair(32))
                        .foregroundStyle(DT.textPrimary)
                    Image(systemName: "leaf")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(DT.heatmapLevel3)
                        .scaleEffect(x: -1, y: 1)
                }
                .modifier(FadeUpModifier(delay: 0.2))

                Text("You did nothing for \(minutes) minutes")
                    .font(DT.inter(14))
                    .foregroundStyle(DT.textSecondary)
                    .modifier(FadeUpModifier(delay: 0.35))

                LegendView(activeLevel: level)
                    .modifier(FadeUpModifier(delay: 0.55))

                Button { nav.currentScreen = .home } label: {
                    Text("Done")
                        .font(DT.inter(14))
                        .foregroundStyle(DT.textMuted)
                }
                .modifier(FadeUpModifier(delay: 0.7))
            }

            // Badge notification
            if showNotification, let badge = nav.lastNewBadges.first {
                VStack {
                    Spacer()
                    BadgeNotificationView(badge: badge) {
                        nav.currentScreen = .badges
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            if !nav.lastNewBadges.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.spring(duration: 0.5)) { showNotification = true }
                }
            }
        }
        .onDisappear {
            showNotification = false
        }
    }

}

struct FadeUpModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : 12)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    appeared = true
                }
            }
    }
}
