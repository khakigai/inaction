import Foundation
import Observation

@Observable
final class AppSettings {
    private let defaults = UserDefaults.standard

    var duration: Int {
        get { defaults.object(forKey: "inaction.duration") as? Int ?? 600 }
        set { defaults.set(newValue, forKey: "inaction.duration") }
    }

    var soundEnabled: Bool {
        get { defaults.object(forKey: "inaction.sound") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "inaction.sound") }
    }

    var hapticEnabled: Bool {
        get { defaults.object(forKey: "inaction.haptic") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "inaction.haptic") }
    }

    var reminderEnabled: Bool {
        get { defaults.object(forKey: "inaction.reminder") as? Bool ?? false }
        set { defaults.set(newValue, forKey: "inaction.reminder") }
    }

    var lastSeenBadgeCount: Int {
        get { defaults.integer(forKey: "inaction.lastSeenBadgeCount") }
        set { defaults.set(newValue, forKey: "inaction.lastSeenBadgeCount") }
    }
}
