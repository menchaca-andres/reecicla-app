import SwiftUI

extension Color {
    static let bgPage      = Color.white
    static let bgCard      = Color.white
    static let bgSubtle    = Color(hex: "e8e8ed")
    static let borderColor = Color.black.opacity(0.08)
    static let borderHover = Color.black.opacity(0.15)

    static let bluePrimary = Color(hex: "0071e3")
    static let blueHover   = Color(hex: "0077ed")
    static let blueLight   = bluePrimary.opacity(0.06)
    static let blueBorder  = bluePrimary.opacity(0.3)

    static let greenPrimary = Color(hex: "34c759")
    static let greenLight   = greenPrimary.opacity(0.1)
    static let greenBorder  = greenPrimary.opacity(0.25)

    static let redPrimary  = Color(hex: "ff3b30")
    static let redLight    = redPrimary.opacity(0.1)
    static let redBorder   = redPrimary.opacity(0.2)

    static let orangePrimary = Color(hex: "ff9500")
    static let orangeLight   = orangePrimary.opacity(0.1)
    static let orangeBorder  = orangePrimary.opacity(0.25)

    static let textMain  = Color(hex: "1d1d1f")
    static let textSecondary = Color(hex: "6e6e73")
    static let textMuted = Color(hex: "86868b")
    static let textLight = Color(hex: "9a9aa0")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
