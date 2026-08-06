import SwiftUI
import SwiftData

struct SetupView: View {
    @Environment(NavigationState.self) private var nav
    @Environment(AppSettings.self) private var settings
    @Query private var sessions: [Session]

    @State private var sliderIndex: Int = 1

    private var hasSessionToday: Bool {
        sessions.contains { $0.dateKey == toDateKey(Date()) }
    }

    var body: some View {
        ZStack {
            DT.cream.ignoresSafeArea()

            VStack(spacing: 48) {
                Button { nav.currentScreen = .home } label: {
                    Text("← Back")
                        .font(DT.inter(13))
                        .foregroundStyle(DT.textSecondary)
                }

                DurationSliderView(selectedIndex: $sliderIndex)

                // Sound toggle
                Button {
                    settings.soundEnabled.toggle()
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Capsule()
                                .fill(settings.soundEnabled ? DT.toggleOn : DT.toggleOff)
                                .frame(width: 40, height: 22)
                            Circle()
                                .fill(.white)
                                .frame(width: 16, height: 16)
                                .offset(x: settings.soundEnabled ? 9 : -9)
                                .animation(.easeInOut(duration: 0.3), value: settings.soundEnabled)
                        }
                        Text("Alpha waves")
                            .font(DT.inter(13))
                            .foregroundStyle(settings.soundEnabled ? Color(hex: "4A4A4A") : DT.textSecondary)
                    }
                }

                Button {
                    guard !hasSessionToday else { return }
                    settings.duration = durationSteps[sliderIndex]
                    nav.currentScreen = .session
                } label: {
                    Text("Start")
                        .font(DT.inter(13, weight: .medium))
                        .kerning(2)
                        .foregroundStyle(DT.textMuted)
                        .frame(width: 76, height: 76)
                        .overlay(Circle().stroke(DT.textMuted, lineWidth: 1.5))
                }
            }
        }
        .onAppear {
            sliderIndex = durationSteps.firstIndex(of: settings.duration) ?? 1
        }
    }
}
