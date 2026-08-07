import Foundation
import WidgetKit

enum WidgetDataManager {
    private static let suiteName = "group.com.khakigai.Inaction"

    static func update(hasSessionToday: Bool, currentStreak: Int) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(hasSessionToday, forKey: "widget.hasSessionToday")
        defaults.set(toDateKey(Date()), forKey: "widget.todayDateKey")
        defaults.set(currentStreak, forKey: "widget.currentStreak")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
