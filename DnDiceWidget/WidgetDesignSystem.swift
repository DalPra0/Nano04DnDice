//
//  WidgetDesignSystem.swift
//  DnDiceWidget
//
//  Design System for Widget (mirrors main app)
//

import SwiftUI

// MARK: - Widget Design System
enum WidgetDesignSystem {
    
    // MARK: - Colors (Dark + Light Mode Support)
    enum Colors {
        // Brand colors (consistent with main app)
        static let brandGold = Color(hex: "#FFD700")
        static let brandGoldDark = Color(hex: "#D4AF37")
        
        // Adaptive backgrounds (automatic dark/light)
        static let backgroundPrimary = Color(uiColor: .systemBackground)
        static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
        static let backgroundTertiary = Color(uiColor: .tertiarySystemBackground)
        
        // Widget-specific gradients (adaptive)
        static func adaptiveGradient(colorScheme: ColorScheme) -> LinearGradient {
            if colorScheme == .dark {
                return LinearGradient(
                    colors: [
                        Color(hex: "#1a1a2e"),
                        Color(hex: "#16213e")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                return LinearGradient(
                    colors: [
                        Color(hex: "#f8f9fa"),
                        Color(hex: "#e9ecef")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        // Text colors (adaptive)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        
        // Semantic colors
        static let success = Color.green
        static let critical = Color.green
        static let fumble = Color.red
    }
    
    // MARK: - Typography (Accessible sizes - 13pt minimum)
    enum Typography {
        // Widget sizes (iOS HIG compliant)
        static let resultSmall = Font.custom("PlayfairDisplay-Black", size: 52)
        static let resultMedium = Font.custom("PlayfairDisplay-Black", size: 72)
        static let resultLarge = Font.custom("PlayfairDisplay-Black", size: 96)
        
        static let title = Font.custom("PlayfairDisplay-Bold", size: 18)
        static let subtitle = Font.custom("PlayfairDisplay-Bold", size: 15)
        static let body = Font.custom("PlayfairDisplay-Regular", size: 14)
        static let caption = Font.custom("PlayfairDisplay-Regular", size: 13) // Minimum
        
        static let diceType = Font.custom("PlayfairDisplay-Bold", size: 16)
        static let critical = Font.custom("PlayfairDisplay-Bold", size: 13)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
}

// MARK: - Color Extension (Helper)
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
