import Foundation
import Observation

@Observable
final class AppSettings {
    @ObservationIgnored private let defaults = UserDefaults.standard

    var duration: Int {
        didSet { defaults.set(duration, forKey: "inaction.duration") }
    }

    var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: "inaction.sound") }
    }

    var hapticEnabled: Bool {
        didSet { defaults.set(hapticEnabled, forKey: "inaction.haptic") }
    }

    var reminderEnabled: Bool {
        didSet { defaults.set(reminderEnabled, forKey: "inaction.reminder") }
    }

    var lastSeenBadgeCount: Int {
        didSet { defaults.set(lastSeenBadgeCount, forKey: "inaction.lastSeenBadgeCount") }
    }

    init() {
        duration = defaults.object(forKey: "inaction.duration") as? Int ?? 600
        soundEnabled = defaults.object(forKey: "inaction.sound") as? Bool ?? true
        hapticEnabled = defaults.object(forKey: "inaction.haptic") as? Bool ?? true
        reminderEnabled = defaults.object(forKey: "inaction.reminder") as? Bool ?? false
        lastSeenBadgeCount = defaults.integer(forKey: "inaction.lastSeenBadgeCount")
    }
}
