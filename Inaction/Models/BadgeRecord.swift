import Foundation
import SwiftData

@Model
final class BadgeRecord {
    @Attribute(.unique) var badgeId: String
    var unlockedAt: Date

    init(badgeId: String) {
        self.badgeId = badgeId
        self.unlockedAt = Date()
    }
}
