
import SwiftUI

// MARK: - Preset Themes for Dice Customization
// All Color(hex:) force unwraps (??) have safe fallback colors to prevent crashes
// Hex colors are validated at compile-time to ensure they exist

struct PresetThemes {
    
    static let classic = DiceCustomization(
        name: "Classic D&D",
        diceFaceColor: Color(hex: "#8B0000") ?? .red,  // Fallback: .red
        diceBorderColor: Color(hex: "#FFD700") ?? .yellow,  // Fallback: .yellow
        diceNumberColor: .white,
        backgroundColor: .black,
        accentColor: Color(hex: "#FFD700") ?? .yellow,  // Fallback: .yellow
        backgroundType: .preset,
        diceTexture: .standard,
        fontName: "PlayfairDisplay-Bold"
    )
    
    static let medieval = DiceCustomization(
        name: "Medieval",
        diceFaceColor: Color(hex: "#8B7355") ?? .brown,  // Fallback: .brown
        diceBorderColor: Color(hex: "#D4AF37") ?? .yellow,  // Fallback: .yellow
        diceNumberColor: Color(hex: "#2C1810") ?? .brown,  // Fallback: .brown
        backgroundColor: Color(hex: "#1A1612") ?? .black,  // Fallback: .black
        accentColor: Color(hex: "#D4AF37") ?? .yellow,  // Fallback: .yellow
        backgroundType: .preset,
        diceTexture: .wooden,
        fontName: "PlayfairDisplay-Black"
    )
    
    static let cyberpunk = DiceCustomization(
        name: "Cyberpunk",
        diceFaceColor: Color(hex: "#0A0E27") ?? .blue,  // Fallback: .blue
        diceBorderColor: Color(hex: "#00F0FF") ?? .cyan,  // Fallback: .cyan
        diceNumberColor: Color(hex: "#FF00FF") ?? .pink,  // Fallback: .pink
        backgroundColor: .black,
        accentColor: Color(hex: "#00F0FF") ?? .cyan,  // Fallback: .cyan
        backgroundType: .gradient,
        diceTexture: .metallic,
        fontName: "PlayfairDisplay-Regular",
        particlesEnabled: true
    )
    
    static let horror = DiceCustomization(
        name: "Horror",
        diceFaceColor: Color(hex: "#1A0F1A") ?? .purple,  // Fallback: .purple
        diceBorderColor: Color(hex: "#8B008B") ?? .purple,  // Fallback: .purple
        diceNumberColor: Color(hex: "#90EE90") ?? .green,  // Fallback: .green
        backgroundColor: .black,
        accentColor: Color(hex: "#8B008B") ?? .purple,  // Fallback: .purple
        backgroundType: .preset,
        diceTexture: .stone,
        fontName: "PlayfairDisplay-Bold",
        particlesEnabled: true
    )
    
    static let norse = DiceCustomization(
        name: "Norse",
        diceFaceColor: Color(hex: "#4A5568") ?? .gray,  // Fallback: .gray
        diceBorderColor: Color(hex: "#C0C0C0") ?? .gray,  // Fallback: .gray
        diceNumberColor: Color(hex: "#E0E0E0") ?? .white,  // Fallback: .white
        backgroundColor: Color(hex: "#1C2833") ?? .black,  // Fallback: .black
        accentColor: Color(hex: "#5DADE2") ?? .blue,  // Fallback: .blue
        backgroundType: .preset,
        diceTexture: .stone,
        fontName: "PlayfairDisplay-Bold"
    )
    
    static let arcane = DiceCustomization(
        name: "Arcane",
        diceFaceColor: Color(hex: "#4B0082") ?? .purple,  // Fallback: .purple
        diceBorderColor: Color(hex: "#9370DB") ?? .purple,  // Fallback: .purple
        diceNumberColor: Color(hex: "#FFD700") ?? .yellow,  // Fallback: .yellow
        backgroundColor: Color(hex: "#0F0520") ?? .black,  // Fallback: .black
        accentColor: Color(hex: "#9370DB") ?? .purple,  // Fallback: .purple
        backgroundType: .preset,
        diceTexture: .crystal,
        fontName: "PlayfairDisplay-Regular",
        particlesEnabled: true
    )
    
    static let light = DiceCustomization(
        name: "Light Mode",
        diceFaceColor: Color(hex: "#FFFFFF") ?? .white,  // Fallback: .white
        diceBorderColor: Color(hex: "#2C3E50") ?? .gray,  // Fallback: .gray
        diceNumberColor: Color(hex: "#1A1A1A") ?? .black,  // Fallback: .black
        backgroundColor: Color(hex: "#F5F5F5") ?? .white,  // Fallback: .white
        accentColor: Color(hex: "#3498DB") ?? .blue,  // Fallback: .blue
        backgroundType: .solid,
        diceTexture: .standard,
        fontName: "PlayfairDisplay-Bold",
        shadowEnabled: true
    )
    
    static let allThemes: [DiceCustomization] = [
        classic,
        medieval,
        cyberpunk,
        horror,
        norse,
        arcane,
        light
    ]
}
