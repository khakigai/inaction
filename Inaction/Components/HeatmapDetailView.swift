import SwiftUI

struct HeatmapDetailView: View {
    let sessions: [String: Int]
    let onDismiss: () -> Void

    @State private var displayedMonth = Date()
    @GestureState private var dragOffset: CGFloat = 0

    private let cellSize: CGFloat = 9
    private let gap: CGFloat = 3
    private let dayLabels = ["M", "", "W", "", "F", "", ""]
    private let weekdayHeaders = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let calendarRows = 6

    var body: some View {
        ZStack {
            DT.cream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                    // Heatmap
                    heatmapSection
                        .padding(.bottom, 16)

                    // Stats row
                    statsRow
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    // Calendar
                    calendarCard
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    // Month navigation
                    monthNavigation
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            HStack(spacing: 12) {
                Image(systemName: "power")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(DT.textPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Inaction Log.")
                        .font(DT.playfair(24))
                        .foregroundStyle(DT.textPrimary)
                    Text("Your journey of doing nothing")
                        .font(DT.inter(12))
                        .foregroundStyle(DT.textMuted)
                }
            }

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
    }

    // MARK: - Stats

    private var statsRow: some View {
        let totalSessions = sessions.count
        let totalSeconds = sessions.values.reduce(0, +)
        let hours = Double(totalSeconds) / 3600.0
        let streak = computeCurrentStreak(from: Array(sessions.keys))

        let hoursText: String = {
            if hours < 1 {
                let formatted = String(format: "%.1f", hours)
                return formatted
            }
            return hours.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", hours)
                : String(format: "%.1f", hours)
        }()

        return HStack(spacing: 0) {
            statItem(value: "\(totalSessions)", label: "sessions")
            Spacer()
            statItem(value: "\(streak)", label: "streak")
            Spacer()
            statItem(value: hoursText, label: "hours")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(DT.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
    }

    private func statItem(value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(DT.inter(14, weight: .semibold))
                .foregroundStyle(DT.textPrimary)
            Text(label)
                .font(DT.inter(12))
                .foregroundStyle(DT.textMuted)
        }
    }

    // MARK: - Heatmap

    private var heatmapSection: some View {
        let columns = HeatmapBuilder.build(sessions: sessions, minColumns: 27)
        let start = HeatmapBuilder.startDate(sessions: sessions, minColumns: 27)

        return ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    monthLabelsRow(columns: columns, startDate: start)
                        .padding(.bottom, 4)

                    HStack(alignment: .top, spacing: 0) {
                        VStack(spacing: gap) {
                            ForEach(0..<7, id: \.self) { row in
                                Text(dayLabels[row])
                                    .font(.system(size: 8, weight: .regular))
                                    .foregroundStyle(DT.textMuted)
                                    .frame(width: 16, height: cellSize)
                            }
                        }

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
                        .fixedSize()
                        .frame(width: cellSize, alignment: .leading)
                } else {
                    Color.clear.frame(width: cellSize, height: 12)
                }
            }
        }
    }

    // MARK: - Calendar

    private var calendarCard: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(DT.inter(12, weight: .medium))
                        .foregroundStyle(DT.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)

            // Swipeable calendar grid
            calendarGrid(for: displayedMonth)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width < -threshold {
                                changeMonth(1)
                            } else if value.translation.width > threshold {
                                changeMonth(-1)
                            }
                        }
                )
        }
        .padding(16)
        .background(DT.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
    }

    private func calendarGrid(for month: Date) -> some View {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count
        let firstDOW = mondayDOW(monthStart)
        let todayKey = toDateKey(Date())

        return VStack(spacing: 0) {
            ForEach(0..<calendarRows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        let dayOffset = row * 7 + col - firstDOW
                        let dayNum = dayOffset + 1

                        if dayNum >= 1 && dayNum <= daysInMonth {
                            let date = calendar.date(byAdding: .day, value: dayNum - 1, to: monthStart)!
                            let key = toDateKey(date)
                            let hasSession = sessions[key] != nil
                            let isToday = key == todayKey

                            dayCellView(day: dayNum, hasSession: hasSession, isToday: isToday)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        } else {
                            let date = calendar.date(byAdding: .day, value: dayOffset, to: monthStart)!
                            let num = calendar.component(.day, from: date)

                            Text("\(num)")
                                .font(DT.inter(14))
                                .foregroundStyle(DT.textMuted.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCellView(day: Int, hasSession: Bool, isToday: Bool) -> some View {
        VStack(spacing: 2) {
            ZStack {
                if isToday {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "E8E4DC"))
                        .frame(width: 34, height: 34)
                }

                Text("\(day)")
                    .font(DT.inter(14, weight: isToday ? .semibold : .regular))
                    .foregroundStyle(DT.textPrimary)
            }

            Circle()
                .fill(hasSession ? DT.heatmapLevel3 : .clear)
                .frame(width: 5, height: 5)
        }
    }

    // MARK: - Month Navigation

    private var monthNavigation: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"

        return HStack {
            Label(formatter.string(from: displayedMonth), systemImage: "calendar")
                .font(DT.inter(14, weight: .medium))
                .foregroundStyle(DT.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(DT.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.06), radius: 2, y: 1)

            Spacer()

            HStack(spacing: 12) {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DT.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(DT.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                }
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DT.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(DT.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                }
            }
        }
    }

    private func changeMonth(_ offset: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = Calendar.current.date(byAdding: .month, value: offset, to: displayedMonth) ?? displayedMonth
        }
    }
}
