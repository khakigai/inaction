import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

enum DT {
    static let cream = Color(hex: "F5F1E8")
    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "757575")
    static let textMuted = Color(hex: "B0A99E")
    static let borderLight = Color(hex: "D0CBC2")
    static let cardBackground = Color.white
    static let sessionBackground = Color(hex: "0d1117")
    static let todayOutline = Color(hex: "E85D04")
    static let dangerRed = Color(hex: "C84747")

    static let heatmapEmpty = Color(hex: "EAE6DE")
    static let heatmapLevel1 = Color(hex: "c6e6a3")
    static let heatmapLevel2 = Color(hex: "85d068")
    static let heatmapLevel3 = Color(hex: "4aad3a")
    static let heatmapLevel4 = Color(hex: "2d8a30")
    static let heatmapLevel5 = Color(hex: "1a6b22")

    static let toggleOn = Color(hex: "B0A99E")
    static let toggleOff = Color(hex: "D0CBC2")

    static func playfair(_ size: CGFloat) -> Font {
        .custom("Playfair Display", size: size).weight(.black)
    }

    static func inter(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Inter", size: size).weight(weight)
    }
}
