import SwiftUI

extension Color {
    static let bgPage      = Color(hex: "f8fafc")
    static let bgCard      = Color.white
    static let bgSubtle    = Color(hex: "f1f5f9")
    static let borderColor = Color(hex: "e2e8f0")
    static let borderHover = Color(hex: "cbd5e1")

    static let bluePrimary = Color(hex: "2563eb")
    static let blueHover   = Color(hex: "1d4ed8")
    static let blueLight   = Color(hex: "eff6ff")
    static let blueBorder  = Color(hex: "bfdbfe")

    static let greenPrimary = Color(hex: "16a34a")
    static let greenLight   = Color(hex: "f0fdf4")
    static let greenBorder  = Color(hex: "bbf7d0")

    static let redPrimary  = Color(hex: "dc2626")
    static let redLight    = Color(hex: "fef2f2")
    static let redBorder   = Color(hex: "fecaca")

    static let orangePrimary = Color(hex: "ea580c")
    static let orangeLight   = Color(hex: "fff7ed")
    static let orangeBorder  = Color(hex: "fed7aa")

    static let textMain  = Color(hex: "0f172a")
    static let textMuted = Color(hex: "64748b")
    static let textLight = Color(hex: "94a3b8")

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
