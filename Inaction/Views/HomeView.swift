import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(NavigationState.self) private var nav
    @Environment(AppSettings.self) private var settings
    @Query private var sessions: [Session]
    @Query private var badgeRecords: [BadgeRecord]

    @State private var pulseAnimation = false
    @State private var showHeatmapDetail = false

    private var sessionDict: [String: Int] {
        Dictionary(sessions.map { ($0.dateKey, $0.durationSeconds) }, uniquingKeysWith: { _, last in last })
    }

    private var hasSessionToday: Bool {
        sessionDict[toDateKey(Date())] != nil
    }

    private var hasNewBadges: Bool {
        badgeRecords.count > settings.lastSeenBadgeCount
    }

    var body: some View {
        ZStack {
            DT.cream.ignoresSafeArea()

            // Top bar
            VStack {
                HStack {
                    Button { nav.currentScreen = .badges } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "star")
                                .font(.system(size: 20, weight: .light))
                                .foregroundStyle(DT.textMuted)
                            if hasNewBadges {
                                Circle()
                                    .fill(DT.todayOutline)
                                    .frame(width: 7, height: 7)
                                    .offset(x: 3, y: -3)
                            }
                        }
                    }
                    Spacer()
                    Button { nav.currentScreen = .settings } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .light))
                            .foregroundStyle(DT.textMuted)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                Spacer()
            }

            // Content
            VStack(spacing: 32) {
                Text("Inaction")
                    .font(DT.playfair(48))
                    .foregroundStyle(DT.textPrimary)

                HeatmapView(sessions: sessionDict, scrollable: false)
                    .padding(.horizontal, 24)
                    .onTapGesture { showHeatmapDetail = true }
            }

            // Start button
            VStack {
                Spacer()
                Button {
                    if !hasSessionToday { nav.currentScreen = .setup }
                } label: {
                    Text(hasSessionToday ? "Done" : "Start")
                        .font(DT.inter(13, weight: .medium))
                        .kerning(2)
                        .foregroundStyle(hasSessionToday ? DT.borderLight : DT.textMuted)
                        .frame(width: 76, height: 76)
                        .overlay(
                            Circle().stroke(hasSessionToday ? DT.borderLight : DT.textMuted, lineWidth: 1.5)
                        )
                }
                .disabled(hasSessionToday)
                .shadow(color: hasSessionToday ? .clear : DT.textMuted.opacity(0.15),
                        radius: pulseAnimation ? 16 : 0)
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showHeatmapDetail) {
            HeatmapDetailView(
                sessions: sessionDict,
                onDismiss: { showHeatmapDetail = false }
            )
            .presentationDetents([.large])
        }
        .onAppear {
            if settings.reminderEnabled {
                NotificationManager.shared.scheduleDailyReminder(
                    hour: settings.reminderHour, minute: settings.reminderMinute
                )
            }
            guard !hasSessionToday else { return }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}
