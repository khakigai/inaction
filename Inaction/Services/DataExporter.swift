import Foundation

struct DataExporter {
    static func exportJSON(sessions: [Session], badges: [BadgeRecord], lastSeenCount: Int) -> Data? {
        var sessionDict = [String: Int]()
        for s in sessions { sessionDict[s.dateKey] = s.durationSeconds }

        var unlockedDict = [String: [String: String]]()
        let iso = ISO8601DateFormatter()
        for b in badges { unlockedDict[b.badgeId] = ["unlockedAt": iso.string(from: b.unlockedAt)] }

        let payload: [String: Any] = [
            "sessions": sessionDict,
            "badges": [
                "unlocked": unlockedDict,
                "lastSeenCount": lastSeenCount
            ]
        ]

        return try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
    }

    static func importJSON(_ data: Data) -> (sessions: [(String, Int)], badges: [(String, Date)], lastSeenCount: Int)? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }

        var sessions = [(String, Int)]()
        if let sessionDict = json["sessions"] as? [String: Int] {
            sessions = sessionDict.map { ($0.key, $0.value) }
        }

        var badges = [(String, Date)]()
        var lastSeenCount = 0
        if let badgeData = json["badges"] as? [String: Any] {
            lastSeenCount = badgeData["lastSeenCount"] as? Int ?? 0
            if let unlocked = badgeData["unlocked"] as? [String: [String: String]] {
                let iso = ISO8601DateFormatter()
                for (id, info) in unlocked {
                    let date = info["unlockedAt"].flatMap { iso.date(from: $0) } ?? Date()
                    badges.append((id, date))
                }
            }
        }

        return (sessions, badges, lastSeenCount)
    }
}
