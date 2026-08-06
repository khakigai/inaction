import SwiftUI

struct HeatmapView: View {
    let sessions: [String: Int]

    private let cellSize: CGFloat = 9
    private let gap: CGFloat = 3
    private let minColumns = 27

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    let columns = buildColumns()
                    HStack(alignment: .top, spacing: gap) {
                        ForEach(Array(columns.enumerated()), id: \.offset) { colIdx, column in
                            VStack(spacing: gap) {
                                ForEach(Array(column.enumerated()), id: \.offset) { _, cell in
                                    cellView(for: cell)
                                }
                            }
                            .id(colIdx)
                        }
                    }
                    .padding(16)
                }
                .onAppear {
                    let cols = buildColumns()
                    if cols.count > 0 {
                        let target = max(0, cols.count - 1)
                        proxy.scrollTo(target, anchor: .trailing)
                    }
                }
            }
        }
        .background(DT.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        .frame(maxWidth: 360)
    }

    @ViewBuilder
    private func cellView(for cell: CellData) -> some View {
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

    private func buildColumns() -> [[CellData]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayKey = toDateKey(today)

        let sessionKeys = sessions.keys.sorted()
        var startDate = today
        if let first = sessionKeys.first, let d = dateFromKey(first) {
            startDate = calendar.startOfDay(for: d)
        }
        // Align to Monday
        let startDOW = mondayDOW(startDate)
        startDate = calendar.date(byAdding: .day, value: -startDOW, to: startDate)!

        let endDOW = mondayDOW(today)
        let endDate = calendar.date(byAdding: .day, value: 6 - endDOW, to: today)!

        // Ensure minimum columns to fill the card width
        let daySpan = calendar.dateComponents([.day], from: startDate, to: endDate).day! + 1
        let totalColumns = (daySpan + 6) / 7
        if totalColumns < minColumns {
            let extraWeeks = minColumns - totalColumns
            startDate = calendar.date(byAdding: .day, value: -extraWeeks * 7, to: startDate)!
        }

        var columns: [[CellData]] = []
        var current = startDate
        var currentColumn: [CellData] = []

        while current <= endDate {
            let key = toDateKey(current)
            let isFuture = current > today
            let level: Int
            if isFuture {
                level = 0
            } else if let sec = sessions[key] {
                level = durationLevel(sec)
            } else {
                level = 0
            }

            currentColumn.append(CellData(
                key: key,
                color: durationLevelColor(level),
                isToday: key == todayKey
            ))

            if currentColumn.count == 7 {
                columns.append(currentColumn)
                currentColumn = []
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        if !currentColumn.isEmpty { columns.append(currentColumn) }
        return columns
    }
}

private struct CellData {
    let key: String
    let color: Color
    let isToday: Bool
}
