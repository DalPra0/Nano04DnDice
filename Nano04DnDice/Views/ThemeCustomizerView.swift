
import SwiftUI
import RevenueCat
import RevenueCatUI

struct ThemeCustomizerView: View {
    @EnvironmentObject private var subManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var customTheme: DiceCustomization
    @State private var themeName: String
    @State private var showSaveAlert = false
    @State private var showColorPicker: ColorPickerType?
    
    private var accentColor: Color {
        customTheme.accentColor.color
    }
    
    enum ColorPickerType: Identifiable {
        case diceFace, diceBorder, diceNumber, background, accent
        var id: Self { self }
    }
    
    init() {
        let currentTheme = ThemeManager.shared.currentTheme
        _customTheme = State(initialValue: currentTheme)
        _themeName = State(initialValue: currentTheme.name)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.black.opacity(0.8), Color.black],
                center: .center,
                startRadius: 100,
                endRadius: 500
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                customHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        mainIconHeader
                        
                        // Theme Name
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("THEME NAME")
                            TextField("Enter theme name...", text: $themeName)
                                .font(.custom("PlayfairDisplay-Bold", size: 18))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                        
                        // Dice Colors
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("DICE ESSENCE")
                            HStack(spacing: 12) {
                                ColorOrb(label: "Face", color: customTheme.diceFaceColor.color) { showColorPicker = .diceFace }
                                ColorOrb(label: "Edge", color: customTheme.diceBorderColor.color) { showColorPicker = .diceBorder }
                                ColorOrb(label: "Runes", color: customTheme.diceNumberColor.color) { showColorPicker = .diceNumber }
                            }
                        }
                        
                        // App Colors
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("REALM COLORS")
                            HStack(spacing: 12) {
                                ColorOrb(label: "Void", color: customTheme.backgroundColor.color) { showColorPicker = .background }
                                ColorOrb(label: "Aura", color: customTheme.accentColor.color) { showColorPicker = .accent }
                            }
                        }
                        
                        // Preview
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("LIVE PREVIEW")
                            ZStack {
                                customTheme.backgroundColor.color
                                DiceDisplayView(
                                    diceSize: 200, 
                                    currentNumber: 20, 
                                    isRolling: false, 
                                    glowIntensity: customTheme.glowIntensity, 
                                    diceBorderColor: customTheme.diceBorderColor.color, 
                                    accentColor: customTheme.accentColor.color, 
                                    diceSides: 20, 
                                    theme: customTheme, 
                                    onRollComplete: { _ in }
                                )
                                .scaleEffect(0.8)
                            }
                            .frame(height: 240)
                            .cornerRadius(24)
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(accentColor.opacity(0.3), lineWidth: 2))
                            .shadow(color: accentColor.opacity(0.2), radius: 20)
                        }
                        
                        // Texture & Font
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionLabel("MATERIAL")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach([DiceCustomization.DiceTexture.standard, .metallic, .wooden, .stone, .crystal], id: \.self) { texture in
                                            TextureSelectionButton(texture: texture, isSelected: customTheme.diceTexture == texture, accentColor: accentColor) {
                                                if texture != .standard && !subManager.isPro {
                                                    subManager.showPaywall = true
                                                } else {
                                                    customTheme.diceTexture = texture
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                sectionLabel("INSCRIPTION STYLE")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(availableFonts, id: \.self) { font in
                                            FontSelectionButton(font: font, isSelected: customTheme.fontName == font, accentColor: accentColor) {
                                                customTheme.fontName = font
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Effects
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("ARCANE EFFECTS")
                            VStack(spacing: 20) {
                                EffectSlider(label: "Glow Intensity", value: $customTheme.glowIntensity, accentColor: accentColor)
                                Toggle(isOn: $customTheme.shadowEnabled) {
                                    Text("Dimensional Shadows")
                                        .font(.custom("PlayfairDisplay-Bold", size: 16))
                                        .foregroundColor(.white)
                                }
                                .tint(accentColor)
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(16)
                        }
                        
                        // Actions
                        HStack(spacing: 16) {
                            ForgeButton(title: "APPLY AURA", color: accentColor, isSecondary: false) {
                                themeManager.applyTheme(customTheme)
                                dismiss()
                            }
                            
                            ForgeButton(title: "SAVE TO FORGE", color: .green, isSecondary: true) {
                                showSaveAlert = true
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $showColorPicker) { type in
            ColorPickerSheet(selectedColor: bindingForColorType(type), title: titleForColorType(type), accentColor: accentColor)
        }
        .sheet(isPresented: $subManager.showPaywall) {
            PaywallView(displayCloseButton: true)
        }
        .alert("Save Theme", isPresented: $showSaveAlert) {
            TextField("Theme Name", text: $themeName)
            Button("Cancel", role: .cancel) {}
            Button("Save") { saveTheme() }
        } message: {
            Text("Enter a name for your custom theme")
        }
    }
    
    private var customHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text("THE FORGE")
                    .font(.custom("PlayfairDisplay-Black", size: 18))
                    .foregroundColor(.white)
                    .tracking(4)
                
                Spacer()
                
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            LinearGradient(
                colors: [Color.clear, accentColor.opacity(0.5), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
        .background(Color.black.opacity(0.8))
    }
    
    private var mainIconHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "hammer.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(accentColor)
                .shadow(color: accentColor.opacity(0.5), radius: 10)
            
            VStack(spacing: 4) {
                Text("Forge your Destiny")
                    .font(.custom("PlayfairDisplay-Bold", size: 24))
                    .foregroundColor(.white)
                Text("Customize every detail of your arcane tool")
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(.top, 24)
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.custom("PlayfairDisplay-Bold", size: 12))
            .foregroundColor(accentColor.opacity(0.8))
            .tracking(3)
            .padding(.leading, 4)
    }
    
    private var availableFonts: [String] {
        ["SF Pro", "BebasNeue-Regular", "MetalMania-Regular", "Pangolin-Regular", "PlayfairDisplay-Regular", "PlayfairDisplay-Bold", "PlayfairDisplay-Black", "SecularOne-Regular", "Ubuntu-Regular", "Ubuntu-Bold"]
    }
    
    private func bindingForColorType(_ type: ColorPickerType) -> Binding<Color> {
        switch type {
        case .diceFace: return Binding(get: { customTheme.diceFaceColor.color }, set: { customTheme.diceFaceColor = CodableColor(color: $0) })
        case .diceBorder: return Binding(get: { customTheme.diceBorderColor.color }, set: { customTheme.diceBorderColor = CodableColor(color: $0) })
        case .diceNumber: return Binding(get: { customTheme.diceNumberColor.color }, set: { customTheme.diceNumberColor = CodableColor(color: $0) })
        case .background: return Binding(get: { customTheme.backgroundColor.color }, set: { customTheme.backgroundColor = CodableColor(color: $0) })
        case .accent: return Binding(get: { customTheme.accentColor.color }, set: { customTheme.accentColor = CodableColor(color: $0) })
        }
    }
    
    private func titleForColorType(_ type: ColorPickerType) -> String {
        switch type {
        case .diceFace: return "Dice Face"; case .diceBorder: return "Dice Border"; case .diceNumber: return "Numbers"; case .background: return "Background"; case .accent: return "Accent"
        }
    }
    
    private func saveTheme() {
        var themeToSave = customTheme
        themeToSave.name = themeName.isEmpty ? "Custom Theme" : themeName
        themeManager.saveCustomTheme(themeToSave)
        themeManager.applyTheme(themeToSave)
        dismiss()
    }
}

// MARK: - Components

struct ColorOrb: View {
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Circle()
                    .fill(color)
                    .frame(width: 50, height: 50)
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 2))
                    .shadow(color: color.opacity(0.4), radius: 8)
                
                Text(label.uppercased())
                    .font(.custom("PlayfairDisplay-Bold", size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
        }
    }
}

struct TextureSelectionButton: View {
    let texture: DiceCustomization.DiceTexture
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                textureIcon
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? accentColor : .white.opacity(0.6))
                
                Text(texture.rawValue.capitalized)
                    .font(.custom("PlayfairDisplay-Bold", size: 10))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? accentColor.opacity(0.15) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? accentColor : Color.white.opacity(0.1), lineWidth: 1))
        }
    }
    
    @ViewBuilder
    private var textureIcon: some View {
        switch texture {
        case .standard: Image(systemName: "square.fill")
        case .metallic: Image(systemName: "bitcoinsign.circle.fill")
        case .wooden: Image(systemName: "leaf.fill")
        case .stone: Image(systemName: "mountain.2.fill")
        case .crystal: Image(systemName: "diamond.fill")
        }
    }
}

struct FontSelectionButton: View {
    let font: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("20")
                    .font(font == "SF Pro" ? .system(size: 24, weight: .bold) : .custom(font, size: 24))
                    .foregroundColor(isSelected ? accentColor : .white)
                
                Text(font.prefix(6))
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? accentColor.opacity(0.15) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? accentColor : Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct EffectSlider: View {
    let label: String
    @Binding var value: Double
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
                    .foregroundColor(.white)
                Spacer()
                Text(String(format: "%.0f%%", value * 100))
                    .font(.custom("PlayfairDisplay-Black", size: 14))
                    .foregroundColor(accentColor)
            }
            Slider(value: $value, in: 0...1).tint(accentColor)
        }
    }
}

struct ForgeButton: View {
    let title: String
    let color: Color
    let isSecondary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("PlayfairDisplay-Black", size: 14))
                .foregroundColor(isSecondary ? color : .black)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(isSecondary ? color.opacity(0.1) : color)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSecondary ? color : Color.clear, lineWidth: 2))
        }
    }
}

struct ColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: Color
    let title: String
    let accentColor: Color
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 32) {
                Text(title.uppercased())
                    .font(.custom("PlayfairDisplay-Black", size: 24))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                ColorPicker("Pick your aura color", selection: $selectedColor, supportsOpacity: true)
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding(32)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(24)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("CONFIRM COLOR")
                        .font(.custom("PlayfairDisplay-Black", size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(accentColor)
                        .cornerRadius(16)
                }
                .padding(24)
            }
        }
    }
}
