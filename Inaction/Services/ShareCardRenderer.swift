import UIKit

struct ShareCardRenderer {
    static func render(badge: BadgeDefinition, totalSessions: Int, totalMinutes: Int) -> UIImage? {
        let size = CGSize(width: 1080, height: 1920)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let centerStyle = NSMutableParagraphStyle()
            centerStyle.alignment = .center
            let mutedColor = UIColor(red: 0.69, green: 0.66, blue: 0.62, alpha: 1)
            let darkColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)

            // Background
            UIColor(red: 0.96, green: 0.95, blue: 0.91, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            // Icon (SF Symbol)
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .light)
            if let symbolImage = UIImage(systemName: badge.icon, withConfiguration: symbolConfig) {
                let tinted = symbolImage.withTintColor(darkColor, renderingMode: .alwaysOriginal)
                let imgSize = tinted.size
                tinted.draw(at: CGPoint(x: (1080 - imgSize.width) / 2, y: 680 - imgSize.height / 2))
            }

            // Badge name
            let nameFont: UIFont = {
                let desc = UIFontDescriptor(name: "PlayfairDisplay-Regular", size: 64).addingAttributes([
                    .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.black]
                ])
                return UIFont(descriptor: desc, size: 64)
            }()
            let nameAttr: [NSAttributedString.Key: Any] = [
                .font: nameFont,
                .foregroundColor: darkColor,
                .paragraphStyle: centerStyle
            ]
            NSAttributedString(string: badge.name, attributes: nameAttr)
                .draw(in: CGRect(x: 0, y: 800, width: 1080, height: 80))

            // Contextual description
            let contextDesc = contextualDescription(for: badge)
            let descFont = UIFont(name: "Inter-Regular", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .light)
            let descAttr: [NSAttributedString.Key: Any] = [
                .font: descFont,
                .foregroundColor: UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1),
                .paragraphStyle: centerStyle
            ]
            NSAttributedString(string: contextDesc, attributes: descAttr)
                .draw(in: CGRect(x: 60, y: 890, width: 960, height: 80))

            // Divider
            UIColor(red: 0.816, green: 0.796, blue: 0.761, alpha: 1).setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 420, y: 1020))
            path.addLine(to: CGPoint(x: 660, y: 1020))
            path.lineWidth = 1
            path.stroke()

            // Stats
            let statsFont = UIFont(name: "Inter-Regular", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .regular)
            let statsAttr: [NSAttributedString.Key: Any] = [
                .font: statsFont,
                .foregroundColor: mutedColor,
                .paragraphStyle: centerStyle
            ]
            let sessionWord = totalSessions == 1 ? "session" : "sessions"
            let minuteWord = totalMinutes == 1 ? "minute" : "minutes"
            let statsText = "\(totalSessions) \(sessionWord) · \(totalMinutes) \(minuteWord) of nothing"
            NSAttributedString(string: statsText, attributes: statsAttr)
                .draw(in: CGRect(x: 0, y: 1060, width: 1080, height: 50))

            // App name
            let logoFont: UIFont = {
                let desc = UIFontDescriptor(name: "PlayfairDisplay-Regular", size: 36).addingAttributes([
                    .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.black]
                ])
                return UIFont(descriptor: desc, size: 36)
            }()
            let logoAttr: [NSAttributedString.Key: Any] = [
                .font: logoFont,
                .foregroundColor: mutedColor,
                .paragraphStyle: centerStyle,
                .kern: 4
            ]
            NSAttributedString(string: "Inaction", attributes: logoAttr)
                .draw(in: CGRect(x: 0, y: 1690, width: 1080, height: 50))

            // Tagline
            let tagFont = UIFont(name: "Inter-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
            let tagAttr: [NSAttributedString.Key: Any] = [
                .font: tagFont,
                .foregroundColor: UIColor(red: 0.76, green: 0.73, blue: 0.69, alpha: 1),
                .paragraphStyle: centerStyle
            ]
            NSAttributedString(string: "An app for doing nothing", attributes: tagAttr)
                .draw(in: CGRect(x: 0, y: 1750, width: 1080, height: 40))
        }
    }

    private static func contextualDescription(for badge: BadgeDefinition) -> String {
        switch badge.category {
        case .streak:
            let days = badge.threshold
            if days == 1 { return "Sat still for the very first day" }
            return "Sat still for \(days) days straight"
        case .session:
            let count = badge.threshold
            if count == 1 { return "Completed the very first session" }
            return "Completed \(count) sessions of doing nothing"
        case .time:
            let hours = badge.threshold / 3600
            if hours == 1 { return "Spent a full hour doing absolutely nothing" }
            return "Spent \(hours) hours doing absolutely nothing"
        }
    }
}
