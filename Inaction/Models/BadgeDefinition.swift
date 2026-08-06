import Foundation

enum BadgeCategory: String, CaseIterable {
    case session, streak, time
}

struct BadgeDefinition: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: BadgeCategory
    let threshold: Int

    static let all: [BadgeDefinition] = [
        // Streak (consecutive days)
        .init(id: "streak-1", name: "Pebble", description: "1-day streak", icon: "circle.fill", category: .streak, threshold: 1),
        .init(id: "streak-10", name: "Stone", description: "10-day streak", icon: "square.stack.fill", category: .streak, threshold: 10),
        .init(id: "streak-50", name: "Boulder", description: "50-day streak", icon: "mountain.2.fill", category: .streak, threshold: 50),
        .init(id: "streak-100", name: "Bedrock", description: "100-day streak", icon: "square.stack.3d.up.fill", category: .streak, threshold: 100),
        .init(id: "streak-300", name: "Mountain", description: "300-day streak", icon: "mountain.2.circle.fill", category: .streak, threshold: 300),
        .init(id: "streak-500", name: "Tectonic", description: "500-day streak", icon: "flame.fill", category: .streak, threshold: 500),
        .init(id: "streak-1000", name: "Diamond", description: "1000-day streak", icon: "diamond.fill", category: .streak, threshold: 1000),
        .init(id: "streak-10000", name: "Planet Core", description: "10000-day streak", icon: "globe.americas.fill", category: .streak, threshold: 10000),

        // Time (total seconds)
        .init(id: "time-1", name: "One Hour Lost", description: "1 hour of nothing", icon: "hourglass", category: .time, threshold: 3600),
        .init(id: "time-10", name: "Time Well Wasted", description: "10 hours of nothing", icon: "clock.fill", category: .time, threshold: 36000),
        .init(id: "time-50", name: "Slow Living", description: "50 hours of nothing", icon: "sun.horizon.fill", category: .time, threshold: 180000),
        .init(id: "time-100", name: "Deep Rest", description: "100 hours of nothing", icon: "water.waves", category: .time, threshold: 360000),
        .init(id: "time-300", name: "Still Water", description: "300 hours of nothing", icon: "drop.fill", category: .time, threshold: 1080000),
        .init(id: "time-500", name: "Empty Mind", description: "500 hours of nothing", icon: "leaf.fill", category: .time, threshold: 1800000),
        .init(id: "time-1000", name: "Beyond Time", description: "1000 hours of nothing", icon: "infinity", category: .time, threshold: 3600000),
        .init(id: "time-10000", name: "Void", description: "10000 hours of nothing", icon: "circle.dashed", category: .time, threshold: 36000000),

        // Session (total count)
        .init(id: "session-1", name: "First Grass", description: "1 session", icon: "leaf", category: .session, threshold: 1),
        .init(id: "session-10", name: "Sprout", description: "10 sessions", icon: "leaf.arrow.circlepath", category: .session, threshold: 10),
        .init(id: "session-50", name: "Young Tree", description: "50 sessions", icon: "tree", category: .session, threshold: 50),
        .init(id: "session-100", name: "Meadow", description: "100 sessions", icon: "tent.fill", category: .session, threshold: 100),
        .init(id: "session-300", name: "Forest", description: "300 sessions", icon: "tree.fill", category: .session, threshold: 300),
        .init(id: "session-500", name: "Timberland", description: "500 sessions", icon: "laurel.leading", category: .session, threshold: 500),
        .init(id: "session-1000", name: "Eternal Garden", description: "1000 sessions", icon: "sparkles", category: .session, threshold: 1000),
        .init(id: "session-10000", name: "Planet Nothing", description: "10000 sessions", icon: "globe", category: .session, threshold: 10000),
    ]
}
