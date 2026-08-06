import SwiftUI
import SwiftData

struct BadgesView: View {
    @Environment(NavigationState.self) private var nav
    @Environment(AppSettings.self) private var settings
    @Query private var sessions: [Session]
    @Query private var badgeRecords: [BadgeRecord]

    @State private var selectedBadge: BadgeDefinition?

    private var unlockedIds: Set<String> {
        Set(badgeRecords.map(\.badgeId))
    }

    private var badgeRecordMap: [String: BadgeRecord] {
        Dictionary(badgeRecords.map { ($0.badgeId, $0) }, uniquingKeysWith: { _, last in last })
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            DT.cream.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Button { nav.currentScreen = .home } label: {
                        Text("← Back")
                            .font(DT.inter(14))
                            .foregroundStyle(DT.textMuted)
                    }
                    .padding(.bottom, 24)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(BadgeCategory.allCases, id: \.rawValue) { category in
                            Section {
                                ForEach(BadgeDefinition.all.filter { $0.category == category }) { badge in
                                    BadgeCardView(
                                        badge: badge,
                                        isUnlocked: unlockedIds.contains(badge.id)
                                    ) {
                                        selectedBadge = badge
                                    }
                                }
                            } header: {
                                Text(category.rawValue.uppercased())
                                    .font(DT.inter(11, weight: .medium))
                                    .foregroundStyle(DT.textMuted)
                                    .kerning(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 12)
                            }
                        }
                    }
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 40)
            }

            // Badge detail overlay
            if let badge = selectedBadge {
                BadgeDetailView(
                    badge: badge,
                    unlockedAt: badgeRecordMap[badge.id]?.unlockedAt,
                    totalSessions: sessions.count,
                    totalMinutes: sessions.map(\.durationSeconds).reduce(0, +) / 60
                ) {
                    withAnimation(.easeOut(duration: 0.25)) { selectedBadge = nil }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.25), value: selectedBadge != nil)
        .onAppear {
            settings.lastSeenBadgeCount = badgeRecords.count
        }
    }
}
