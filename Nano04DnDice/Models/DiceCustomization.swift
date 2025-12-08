
import SwiftUI

struct DiceCustomization: Codable, Identifiable {
    var id = UUID()
    var name: String
    
    var diceFaceColor: CodableColor
    var diceBorderColor: CodableColor
    var diceNumberColor: CodableColor
    var backgroundColor: CodableColor
    var accentColor: CodableColor
    
    var backgroundType: BackgroundType
    var customBackgroundImageName: String?
    
    var diceTexture: DiceTexture
    
    var fontName: String
    
    var glowIntensity: Double
    var shadowEnabled: Bool
    var particlesEnabled: Bool
    
    var proficiencyBonus: Int
    
    enum BackgroundType: String, Codable {
        case solid
        case gradient
        case image
        case preset
    }
    
    enum DiceTexture: String, Codable {
        case standard
        case metallic
        case wooden
        case stone
        case crystal
    }
    
    init(
        name: String = "Novo Tema",
        diceFaceColor: Color = .white,
        diceBorderColor: Color = Color(hex: "#FFD700")!,
        diceNumberColor: Color = .black,
        backgroundColor: Color = .black,
        accentColor: Color = Color(hex: "#FFD700")!,
        backgroundType: BackgroundType = .solid,
        customBackgroundImageName: String? = nil,
        diceTexture: DiceTexture = .standard,
        fontName: String = "PlayfairDisplay-Regular",
        glowIntensity: Double = 0.3,
        shadowEnabled: Bool = true,
        particlesEnabled: Bool = false,
        proficiencyBonus: Int = 0
    ) {
        self.name = name
        self.diceFaceColor = CodableColor(color: diceFaceColor)
        self.diceBorderColor = CodableColor(color: diceBorderColor)
        self.diceNumberColor = CodableColor(color: diceNumberColor)
        self.backgroundColor = CodableColor(color: backgroundColor)
        self.accentColor = CodableColor(color: accentColor)
        self.backgroundType = backgroundType
        self.customBackgroundImageName = customBackgroundImageName
        self.diceTexture = diceTexture
        self.fontName = fontName
        self.glowIntensity = glowIntensity
        self.shadowEnabled = shadowEnabled
        self.particlesEnabled = particlesEnabled
        self.proficiencyBonus = proficiencyBonus
    }
}


struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// Color hex extension moved to Color+Hex.swift for better organization
