import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    private let identifier = "daily-reminder"

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        cancelReminder()

        let content = makeContent()
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func skipToday(hour: Int, minute: Int) {
        cancelReminder()

        let content = makeContent()
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return }
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    private func makeContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Inaction"
        content.body = "A few minutes of nothing goes a long way."
        content.sound = .default
        return content
    }
}
