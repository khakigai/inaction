import Foundation

struct BadgeEvaluator {
    static func evaluate(sessions: [Session], alreadyUnlocked: Set<String>) -> [BadgeDefinition] {
        let totalSessions = sessions.count
        let maxStreak = computeMaxStreak(from: sessions.map(\.dateKey))
        let totalSeconds = sessions.map(\.durationSeconds).reduce(0, +)

        return BadgeDefinition.all.compactMap { badge in
            guard !alreadyUnlocked.contains(badge.id) else { return nil }
            let met: Bool
            switch badge.category {
            case .session: met = totalSessions >= badge.threshold
            case .streak: met = maxStreak >= badge.threshold
            case .time: met = totalSeconds >= badge.threshold
            }
            return met ? badge : nil
        }
    }
}
