import SwiftUI

// MARK: - Design System
// Centraliza spacing, typography, colors para consistência em todo o app

enum DesignSystem {
    
    // MARK: - Spacing Scale
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        // Consistent corner radius
        static let radiusSmall: CGFloat = 8
        static let radiusMedium: CGFloat = 12
        static let radiusLarge: CGFloat = 16
        static let radiusXLarge: CGFloat = 24
    }
    
    // MARK: - Typography
    enum Typography {
        // Display
        static let displayLarge = Font.custom("PlayfairDisplay-Black", size: 72)
        static let displayMedium = Font.custom("PlayfairDisplay-Black", size: 56)
        static let displaySmall = Font.custom("PlayfairDisplay-Black", size: 48)
        
        // Headings
        static let h1 = Font.custom("PlayfairDisplay-Bold", size: 32)
        static let h2 = Font.custom("PlayfairDisplay-Bold", size: 28)
        static let h3 = Font.custom("PlayfairDisplay-Bold", size: 24)
        static let h4 = Font.custom("PlayfairDisplay-Bold", size: 20)
        
        // Body
        static let bodyLarge = Font.custom("PlayfairDisplay-Regular", size: 18)
        static let body = Font.custom("PlayfairDisplay-Regular", size: 16)
        static let bodySmall = Font.custom("PlayfairDisplay-Regular", size: 14)
        
        // Labels
        static let label = Font.custom("PlayfairDisplay-Bold", size: 16)
        static let labelSmall = Font.custom("PlayfairDisplay-Bold", size: 14)
        static let caption = Font.custom("PlayfairDisplay-Regular", size: 12)
        static let overline = Font.custom("PlayfairDisplay-Bold", size: 11)
    }
    
    // MARK: - Colors (WCAG AA compliant)
    enum Colors {
        // Text colors with proper contrast
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.8)  // Increased from 0.7
        static let textTertiary = Color.white.opacity(0.6)   // Increased from 0.5
        static let textDisabled = Color.white.opacity(0.4)   // Increased from 0.25
        
        // Background
        static let backgroundPrimary = Color.black
        static let backgroundSecondary = Color.black.opacity(0.8)
        static let backgroundTertiary = Color.black.opacity(0.6)
        
        // Surface
        static let surfaceElevated = Color(.systemGray6)
        static let surfaceOverlay = Color.black.opacity(0.7)
        static let surfaceCard = Color.black.opacity(0.6)
        
        // Overlays (for buttons, backgrounds with less opacity)
        static let backgroundOverlay = Color.white.opacity(0.15)  // Slightly more visible than 0.1
        static let borderSubtle = Color.white.opacity(0.3)
        
        // Semantic colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
    }
    
    // MARK: - Button Sizes (Touch Targets - minimum 44x44pt)
    enum ButtonSize {
        case small
        case medium
        case large
        
        var height: CGFloat {
            switch self {
            case .small: return 44  // Minimum touch target
            case .medium: return 52
            case .large: return 60
            }
        }
        
        var minWidth: CGFloat {
            switch self {
            case .small: return 44  // Minimum touch target
            case .medium: return 120
            case .large: return 200
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return DesignSystem.Spacing.radiusSmall
            case .medium: return DesignSystem.Spacing.radiusMedium
            case .large: return DesignSystem.Spacing.radiusLarge
            }
        }
        
        var font: Font {
            switch self {
            case .small: return DesignSystem.Typography.labelSmall
            case .medium: return DesignSystem.Typography.label
            case .large: return DesignSystem.Typography.bodyLarge
            }
        }
    }
    
    // MARK: - Animation Durations
    enum Animation {
        static let fast = 0.2
        static let normal = 0.3
        static let slow = 0.5
        
        static let springResponse = 0.5
        static let springDamping = 0.7
    }
    
    // MARK: - Safe Area Insets
    enum SafeArea {
        static let minimumPadding: CGFloat = 16
        static let landscapePadding: CGFloat = 20
        static let portraitPadding: CGFloat = 16
    }
}

// MARK: - View Extensions for Design System

extension View {
    
    /// Apply standard spacing
    func spacing(_ size: CGFloat) -> some View {
        self.padding(size)
    }
    
    /// Apply WCAG AA compliant text color
    func textStyle(_ level: TextLevel) -> some View {
        self.foregroundColor(level.color)
    }
    
    /// Apply minimum touch target size (44x44pt)
    func minimumTouchTarget() -> some View {
        self.frame(minWidth: 44, minHeight: 44)
    }
    
    /// Apply surface elevation
    func surfaceStyle(elevation: SurfaceElevation = .medium) -> some View {
        self
            .background(elevation.color)
            .cornerRadius(elevation.cornerRadius)
    }
}

// MARK: - Supporting Enums

enum TextLevel {
    case primary
    case secondary
    case tertiary
    case disabled
    
    var color: Color {
        switch self {
        case .primary: return DesignSystem.Colors.textPrimary
        case .secondary: return DesignSystem.Colors.textSecondary
        case .tertiary: return DesignSystem.Colors.textTertiary
        case .disabled: return DesignSystem.Colors.textDisabled
        }
    }
}

enum SurfaceElevation {
    case low
    case medium
    case high
    
    var color: Color {
        switch self {
        case .low: return DesignSystem.Colors.surfaceCard
        case .medium: return DesignSystem.Colors.surfaceOverlay
        case .high: return DesignSystem.Colors.surfaceElevated
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .low: return DesignSystem.Spacing.radiusMedium
        case .medium: return DesignSystem.Spacing.radiusLarge
        case .high: return DesignSystem.Spacing.radiusXLarge
        }
    }
}
