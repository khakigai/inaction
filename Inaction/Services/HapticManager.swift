import UIKit

struct HapticManager {
    static func impact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func completion() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}
