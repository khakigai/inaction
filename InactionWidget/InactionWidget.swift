import WidgetKit
import SwiftUI

private let suiteName = "group.com.khakigai.Inaction"

struct InactionEntry: TimelineEntry {
    let date: Date
    let hasSessionToday: Bool
    let currentStreak: Int
}

struct InactionProvider: TimelineProvider {
    func placeholder(in context: Context) -> InactionEntry {
        InactionEntry(date: Date(), hasSessionToday: false, currentStreak: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (InactionEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InactionEntry>) -> Void) {
        let entry = readEntry()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func readEntry() -> InactionEntry {
        let defaults = UserDefaults(suiteName: suiteName)
        let todayKey = Self.dateKey(Date())
        let storedKey = defaults?.string(forKey: "widget.todayDateKey") ?? ""
        let hasSession = storedKey == todayKey && (defaults?.bool(forKey: "widget.hasSessionToday") ?? false)
        let streak = defaults?.integer(forKey: "widget.currentStreak") ?? 0
        return InactionEntry(date: Date(), hasSessionToday: hasSession, currentStreak: streak)
    }

    private static func dateKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }
}

struct InactionWidgetEntryView: View {
    var entry: InactionEntry

    private let cream = Color(red: 0.96, green: 0.95, blue: 0.91)
    private let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
    private let textMuted = Color(red: 0.69, green: 0.66, blue: 0.62)
    private let grassGreen = Color(red: 0.29, green: 0.68, blue: 0.23)

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: entry.hasSessionToday ? "leaf.fill" : "leaf")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(entry.hasSessionToday ? grassGreen : textMuted)
                .scaleEffect(x: -1, y: 1)

            Text(entry.hasSessionToday ? "Grass planted" : "Plant your grass")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(entry.hasSessionToday ? textPrimary : textMuted)

            if entry.currentStreak > 1 {
                Text("\(entry.currentStreak) day streak")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(textMuted)
            }
        }
        .containerBackground(cream, for: .widget)
    }
}

struct InactionWidget: Widget {
    let kind = "InactionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InactionProvider()) { entry in
            InactionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Inaction")
        .description("Track your daily grass planting.")
        .supportedFamilies([.systemSmall])
    }
}
