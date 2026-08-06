import Foundation
import SwiftData

@Model
final class Session {
    @Attribute(.unique) var dateKey: String
    var durationSeconds: Int
    var completedAt: Date

    init(dateKey: String, durationSeconds: Int) {
        self.dateKey = dateKey
        self.durationSeconds = durationSeconds
        self.completedAt = Date()
    }
}
