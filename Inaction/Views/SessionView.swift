import SwiftUI
import SwiftData

struct SessionView: View {
    @Environment(NavigationState.self) private var nav
    @Environment(AppSettings.self) private var settings
    @Environment(AudioEngine.self) private var audio
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [Session]
    @Query private var badgeRecords: [BadgeRecord]

    @State private var startTime: Date?
    @State private var remaining: Int = 0

    var body: some View {
        ZStack {
            DT.sessionBackground.ignoresSafeArea()

            VStack(spacing: 48) {
                BreathingCircleView()

                Text(timerString)
                    .font(DT.inter(40, weight: .light))
                    .monospacedDigit()
                    .kerning(4)
                    .foregroundStyle(Color(hex: "484f58"))

                Button { quitSession() } label: {
                    Text("Quit")
                        .font(DT.inter(13))
                        .kerning(1)
                        .foregroundStyle(Color(hex: "484f58"))
                }
            }
        }
        .onAppear {
            remaining = settings.duration
            startTime = Date()
            UIApplication.shared.isIdleTimerDisabled = true
            if settings.soundEnabled { audio.startBrownNoise() }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()) { _ in
            guard let start = startTime else { return }
            let elapsed = Int(Date().timeIntervalSince(start))
            remaining = max(0, settings.duration - elapsed)
            if remaining <= 0 { completeSession() }
        }
    }

    private var timerString: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func completeSession() {
        startTime = nil
        audio.stopBrownNoise()

        let duration = settings.duration
        let session = Session(dateKey: toDateKey(Date()), durationSeconds: duration)
        modelContext.insert(session)
        try? modelContext.save()

        if settings.hapticEnabled { HapticManager.completion() }

        let unlocked = Set(badgeRecords.map(\.badgeId))
        let allSessions = sessions + [session]
        let newBadges = BadgeEvaluator.evaluate(sessions: allSessions, alreadyUnlocked: unlocked)
        for badge in newBadges {
            modelContext.insert(BadgeRecord(badgeId: badge.id))
        }
        try? modelContext.save()

        let allDateKeys = allSessions.map(\.dateKey)
        let streak = computeCurrentStreak(from: allDateKeys)
        WidgetDataManager.update(hasSessionToday: true, currentStreak: streak)

        if settings.reminderEnabled {
            NotificationManager.shared.skipToday(
                hour: settings.reminderHour, minute: settings.reminderMinute
            )
        }

        nav.lastCompletedDuration = duration
        nav.lastNewBadges = newBadges
        nav.currentScreen = .complete

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            audio.playChime()
        }
    }

    private func quitSession() {
        startTime = nil
        audio.stopBrownNoise()
        nav.currentScreen = .home
    }
}
