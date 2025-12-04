
import SwiftUI

struct PresetThemes {
    
    static let classic = DiceCustomization(
        name: "Classic D&D",
        diceFaceColor: Color(hex: "#8B0000") ?? .red,
        diceBorderColor: Color(hex: "#FFD700") ?? .yellow,
        diceNumberColor: .white,
        backgroundColor: .black,
        accentColor: Color(hex: "#FFD700") ?? .yellow,
        backgroundType: .preset,
        diceTexture: .standard,
        fontName: "PlayfairDisplay-Bold",
        glowIntensity: 0.0,
        shadowEnabled: false,
        particlesEnabled: false,
        proficiencyBonus: 0
    )
    
    static let medieval = DiceCustomization(
        name: "Medieval",
        diceFaceColor: Color(hex: "#8B7355") ?? .brown,
        diceBorderColor: Color(hex: "#D4AF37") ?? .yellow,
        diceNumberColor: Color(hex: "#2C1810") ?? .brown,
        backgroundColor: Color(hex: "#1A1612") ?? .black,
        accentColor: Color(hex: "#D4AF37") ?? .yellow,
        backgroundType: .preset,
        diceTexture: .wooden,
        fontName: "PlayfairDisplay-Black",
        glowIntensity: 0.0,
        shadowEnabled: false,
        particlesEnabled: false,
        proficiencyBonus: 0
    )
    
    static let cyberpunk = DiceCustomization(
        name: "Cyberpunk",
        diceFaceColor: Color(hex: "#0A0E27") ?? .blue,
        diceBorderColor: Color(hex: "#00F0FF") ?? .cyan,
        diceNumberColor: Color(hex: "#FF00FF") ?? .pink,
        backgroundColor: .black,
        accentColor: Color(hex: "#00F0FF") ?? .cyan,
        backgroundType: .gradient,
        diceTexture: .metallic,
        fontName: "PlayfairDisplay-Regular",
        glowIntensity: 0.0,
        shadowEnabled: false,
        particlesEnabled: true,
        proficiencyBonus: 0
    )
    
    static let horror = DiceCustomization(
        name: "Horror",
        diceFaceColor: Color(hex: "#1A0F1A") ?? .purple,
        diceBorderColor: Color(hex: "#8B008B") ?? .purple,
        diceNumberColor: Color(hex: "#90EE90") ?? .green,
        backgroundColor: .black,
        accentColor: Color(hex: "#8B008B") ?? .purple,
        backgroundType: .preset,
        diceTexture: .stone,
        fontName: "PlayfairDisplay-Bold",
        glowIntensity: 0.0,
        shadowEnabled: false,
        particlesEnabled: true,
        proficiencyBonus: 0
    )
    
    static let norse = DiceCustomization(
        name: "Norse",
        diceFaceColor: Color(hex: "#4A5568") ?? .gray,
        diceBorderColor: Color(hex: "#C0C0C0") ?? .gray,
        diceNumberColor: Color(hex: "#E0E0E0") ?? .white,
        backgroundColor: Color(hex: "#1C2833") ?? .black,
        accentColor: Color(hex: "#5DADE2") ?? .blue,
        backgroundType: .preset,
        diceTexture: .stone,
        fontName: "PlayfairDisplay-Bold",
        glowIntensity: 0.0,
        shadowEnabled: false,
        particlesEnabled: false,
        proficiencyBonus: 0
    )
    
    static let arcane = DiceCustomization(
        name: "Arcane",
        diceFaceColor: Color(hex: "#4B0082") ?? .purple,
        diceBorderColor: Color(hex: "#9370DB") ?? .purple,
        diceNumberColor: Color(hex: "#FFD700") ?? .yellow,
        backgroundColor: Color(hex: "#0F0520") ?? .black,
        accentColor: Color(hex: "#9370DB") ?? .purple,
        backgroundType: .preset,
        diceTexture: .crystal,
        fontName: "PlayfairDisplay-Regular",
        glowIntensity: 0.0,
        shadowEnabled: false,
        particlesEnabled: true,
        proficiencyBonus: 0
    )
    
    static let light = DiceCustomization(
        name: "Light Mode",
        diceFaceColor: Color(hex: "#FFFFFF") ?? .white,
        diceBorderColor: Color(hex: "#2C3E50") ?? .gray,
        diceNumberColor: Color(hex: "#1A1A1A") ?? .black,
        backgroundColor: Color(hex: "#F5F5F5") ?? .white,
        accentColor: Color(hex: "#3498DB") ?? .blue,
        backgroundType: .solid,
        diceTexture: .standard,
        fontName: "PlayfairDisplay-Bold",
        glowIntensity: 0.0,
        shadowEnabled: true,
        particlesEnabled: false,
        proficiencyBonus: 0
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
