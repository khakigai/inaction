import SwiftUI

struct HeatmapView: View {
    let sessions: [String: Int]
    var scrollable: Bool = true

    private let cellSize: CGFloat = 9
    private let gap: CGFloat = 3
    private let fixedColumns = 27

    var body: some View {
        let columns = buildColumns()

        Group {
            if scrollable {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        gridContent(columns: columns)
                    }
                    .onAppear {
                        if columns.count > 0 {
                            proxy.scrollTo(max(0, columns.count - 1), anchor: .trailing)
                        }
                    }
                }
            } else {
                gridContent(columns: Array(columns.suffix(fixedColumns)))
            }
        }
        .padding(16)
        .background(DT.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        .frame(maxWidth: 360)
    }

    private func gridContent(columns: [[CellData]]) -> some View {
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
        HeatmapBuilder.build(sessions: sessions, minColumns: fixedColumns)
    }
}

struct CellData {
    let key: String
    let color: Color
    let isToday: Bool
}

enum HeatmapBuilder {
    static func build(sessions: [String: Int], minColumns: Int) -> [[CellData]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayKey = toDateKey(today)

        let sessionKeys = sessions.keys.sorted()
        var startDate = today
        if let first = sessionKeys.first, let d = dateFromKey(first) {
            startDate = calendar.startOfDay(for: d)
        }
        let startDOW = mondayDOW(startDate)
        startDate = calendar.date(byAdding: .day, value: -startDOW, to: startDate)!

        let endDOW = mondayDOW(today)
        let endDate = calendar.date(byAdding: .day, value: 6 - endDOW, to: today)!

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

    static func startDate(sessions: [String: Int], minColumns: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let sessionKeys = sessions.keys.sorted()
        var start = today
        if let first = sessionKeys.first, let d = dateFromKey(first) {
            start = calendar.startOfDay(for: d)
        }
        let startDOW = mondayDOW(start)
        start = calendar.date(byAdding: .day, value: -startDOW, to: start)!

        let endDOW = mondayDOW(today)
        let endDate = calendar.date(byAdding: .day, value: 6 - endDOW, to: today)!

        let daySpan = calendar.dateComponents([.day], from: start, to: endDate).day! + 1
        let totalColumns = (daySpan + 6) / 7
        if totalColumns < minColumns {
            let extraWeeks = minColumns - totalColumns
            start = calendar.date(byAdding: .day, value: -extraWeeks * 7, to: start)!
        }
        return start
    }
}
