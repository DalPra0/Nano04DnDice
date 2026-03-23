
import SwiftUI

/// Design System for Widget (Mirrors main app's DesignSystem.swift)
enum WidgetDesignSystem {
    
    enum Colors {
        static let gold = Color(hex: "#FFD700")
        static let deepGold = Color(hex: "#D4AF37")
        static let background = Color.black
        static let backgroundOverlay = Color.white.opacity(0.15)
        
        static func resultColor(isCrit: Bool, isFumble: Bool) -> Color {
            if isCrit { return .green }
            if isFumble { return .red }
            return gold
        }
    }
    
    enum Typography {
        static let display = Font.custom("PlayfairDisplay-Black", size: 64)
        static let title = Font.custom("PlayfairDisplay-Bold", size: 18)
        static let label = Font.custom("PlayfairDisplay-Bold", size: 14)
        static let caption = Font.custom("PlayfairDisplay-Regular", size: 12)
    }
    
    enum Spacing {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
    }
}

// MARK: - Hex Color Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
