import SwiftUI

struct HeatmapDetailView: View {
    let sessions: [String: Int]
    let totalSessions: Int
    let totalMinutes: Int
    let onDismiss: () -> Void

    private let cellSize: CGFloat = 9
    private let gap: CGFloat = 3
    private let dayLabels = ["M", "", "W", "", "F", "", ""]

    var body: some View {
        ZStack {
            DT.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DT.textMuted)
                            .frame(width: 32, height: 32)
                            .background(DT.cardBackground)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Stats
                statsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                // Heatmap with labels
                heatmapSection
                    .padding(.bottom, 20)

                // Legend
                legendSection
                    .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private var statsSection: some View {
        let streak = computeCurrentStreak(from: Array(sessions.keys))
        let maxStreak = computeMaxStreak(from: Array(sessions.keys))

        return VStack(spacing: 0) {
            statRow("Current streak", value: "\(streak) \(streak == 1 ? "day" : "days")")
            Divider().foregroundStyle(Color(hex: "F0ECE4")).padding(.vertical, 10)
            statRow("Longest streak", value: "\(maxStreak) \(maxStreak == 1 ? "day" : "days")")
            Divider().foregroundStyle(Color(hex: "F0ECE4")).padding(.vertical, 10)
            statRow("Total sessions", value: "\(totalSessions)")
            Divider().foregroundStyle(Color(hex: "F0ECE4")).padding(.vertical, 10)
            statRow("Total minutes", value: "\(totalMinutes)")
        }
        .padding(16)
        .background(DT.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DT.inter(14))
                .foregroundStyle(DT.textSecondary)
            Spacer()
            Text(value)
                .font(DT.inter(14, weight: .medium))
                .foregroundStyle(DT.textPrimary)
        }
    }

    private var heatmapSection: some View {
        let columns = HeatmapBuilder.build(sessions: sessions, minColumns: 27)
        let start = HeatmapBuilder.startDate(sessions: sessions, minColumns: 27)

        return VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Month labels
                        monthLabelsRow(columns: columns, startDate: start)
                            .padding(.bottom, 4)

                        // Grid with day labels
                        HStack(alignment: .top, spacing: 0) {
                            // Day labels
                            VStack(spacing: gap) {
                                ForEach(0..<7, id: \.self) { row in
                                    Text(dayLabels[row])
                                        .font(.system(size: 8, weight: .regular))
                                        .foregroundStyle(DT.textMuted)
                                        .frame(width: 16, height: cellSize)
                                }
                            }

                            // Cells
                            HStack(alignment: .top, spacing: gap) {
                                ForEach(Array(columns.enumerated()), id: \.offset) { colIdx, column in
                                    VStack(spacing: gap) {
                                        ForEach(Array(column.enumerated()), id: \.offset) { _, cell in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(cell.color)
                                                .frame(width: cellSize, height: cellSize)
                                                .overlay {
                                                    if cell.isToday {
                                                        RoundedRectangle(cornerRadius: 2)
                                                            .stroke(DT.todayOutline, lineWidth: 1.5)
                                                    }
                                                }
                                        }
                                    }
                                    .id(colIdx)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                .onAppear {
                    if columns.count > 0 {
                        proxy.scrollTo(max(0, columns.count - 1), anchor: .trailing)
                    }
                }
            }
        }
        .background(DT.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        .padding(.horizontal, 24)
    }

    private func monthLabelsRow(columns: [[CellData]], startDate: Date) -> some View {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        return HStack(alignment: .top, spacing: gap) {
            // Offset for day labels column
            Color.clear.frame(width: 16, height: 12)

            ForEach(Array(columns.enumerated()), id: \.offset) { colIdx, _ in
                let mondayDate = calendar.date(byAdding: .day, value: colIdx * 7, to: startDate)!
                let month = calendar.component(.month, from: mondayDate)
                let prevMonth: Int? = colIdx > 0
                    ? calendar.component(.month, from: calendar.date(byAdding: .day, value: (colIdx - 1) * 7, to: startDate)!)
                    : nil

                if prevMonth == nil || month != prevMonth {
                    Text(formatter.string(from: mondayDate))
                        .font(.system(size: 8, weight: .regular))
                        .foregroundStyle(DT.textMuted)
                        .frame(width: cellSize, alignment: .leading)
                } else {
                    Color.clear.frame(width: cellSize, height: 12)
                }
            }
        }
    }

    private var legendSection: some View {
        HStack(spacing: 8) {
            Text("Less")
                .font(.system(size: 10))
                .foregroundStyle(DT.textMuted)
            ForEach(0...5, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(durationLevelColor(level))
                    .frame(width: 9, height: 9)
            }
            Text("More")
                .font(.system(size: 10))
                .foregroundStyle(DT.textMuted)
        }
    }
}
