//
//  DiceCustomization.swift
//  Nano04DnDice
//
//  Modelo de customização visual dos dados
//

import SwiftUI

struct DiceCustomization: Codable, Identifiable {
    var id = UUID()
    var name: String
    
    // Cores
    var diceFaceColor: CodableColor
    var diceBorderColor: CodableColor
    var diceNumberColor: CodableColor
    var backgroundColor: CodableColor
    var accentColor: CodableColor
    
    // Background
    var backgroundType: BackgroundType
    var customBackgroundImageName: String?
    
    // Textura do dado
    var diceTexture: DiceTexture
    
    // Fonte
    var fontName: String
    
    // Efeitos
    var glowIntensity: Double
    var shadowEnabled: Bool
    var particlesEnabled: Bool
    
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
    
    // Inicializador padrão
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
        particlesEnabled: Bool = false
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
    }
}

// MARK: - CodableColor (para salvar Color no Core Data)

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

// MARK: - Color Extension para Hex

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let length = hexSanitized.count
        let r, g, b, a: Double
        
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    func toHex() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format: "#%06x", rgb)
    }
}
