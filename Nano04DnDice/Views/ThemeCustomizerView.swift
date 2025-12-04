
import SwiftUI

struct ThemeCustomizerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var customTheme: DiceCustomization
    @State private var themeName: String
    @State private var showSaveAlert = false
    @State private var showColorPicker: ColorPickerType?
    
    enum ColorPickerType {
        case diceFace, diceBorder, diceNumber, background, accent
    }
    
    init() {
        let currentTheme = ThemeManager.shared.currentTheme
        _customTheme = State(initialValue: currentTheme)
        _themeName = State(initialValue: currentTheme.name)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        
                        themeNameSection
                        
                        diceColorsSection
                        
                        appColorsSection
                        
                        textureSection
                        
                        fontSection
                        
                        effectsSection
                        
                        previewSection
                        
                        buttonsSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FFD700"))
                }
            }
            .alert("Save Theme", isPresented: $showSaveAlert) {
                TextField("Theme Name", text: $themeName)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    saveTheme()
                }
            } message: {
                Text("Enter a name for your custom theme")
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 60))
            
            Text("Create your Theme")
                .font(.custom("PlayfairDisplay-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Customize colors, textures and effects")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.bottom, 10)
    }
    
    
    private var themeNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "THEME NAME")
            
            TextField("Theme Name", text: $themeName)
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    
    private var diceColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "DICE COLORS")
            
            colorButton(
                title: "Dice Face",
                color: customTheme.diceFaceColor.color,
                action: { showColorPicker = .diceFace }
            )
            
            colorButton(
                title: "Dice Border",
                color: customTheme.diceBorderColor.color,
                action: { showColorPicker = .diceBorder }
            )
            
            colorButton(
                title: "Numbers",
                color: customTheme.diceNumberColor.color,
                action: { showColorPicker = .diceNumber }
            )
        }
        .sheet(item: $showColorPicker) { type in
            ColorPickerSheet(
                selectedColor: bindingForColorType(type),
                title: titleForColorType(type)
            )
        }
    }
    
    
    private var appColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "APP COLORS")
            
            colorButton(
                title: "Background",
                color: customTheme.backgroundColor.color,
                action: { showColorPicker = .background }
            )
            
            colorButton(
                title: "Accent (Buttons/Borders)",
                color: customTheme.accentColor.color,
                action: { showColorPicker = .accent }
            )
        }
    }
    
    
    private var textureSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "DICE TEXTURE")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([
                        DiceCustomization.DiceTexture.standard,
                        .metallic,
                        .wooden,
                        .stone,
                        .crystal
                    ], id: \.self) { texture in
                        textureButton(texture)
                    }
                }
            }
        }
    }
    
    private func textureButton(_ texture: DiceCustomization.DiceTexture) -> some View {
        Button(action: {
            customTheme.diceTexture = texture
        }) {
            VStack(spacing: 8) {
                textureIcon(for: texture)
                    .font(.system(size: 30))
                    .foregroundColor(customTheme.diceTexture == texture ? customTheme.accentColor.color : .white)
                
                Text(texture.rawValue.capitalized)
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                customTheme.diceTexture == texture ? customTheme.accentColor.color : Color.white.opacity(0.3),
                                lineWidth: customTheme.diceTexture == texture ? 2 : 1
                            )
                    )
            )
        }
    }
    
    private func textureIcon(for texture: DiceCustomization.DiceTexture) -> some View {
        switch texture {
        case .standard: return Text("Standard")
        case .metallic: return Text("Metallic")
        case .wooden: return Text("Wooden")
        case .stone: return Text("Stone")
        case .crystal: return Text("Crystal")
        }
    }
    
    
    private var fontSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "FONT")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableFonts, id: \.self) { font in
                        fontButton(font)
                    }
                }
            }
        }
    }
    
    private var availableFonts: [String] {
        [
            "SF Pro",
            "BebasNeue-Regular",
            "MetalMania-Regular",
            "Pangolin-Regular",
            "PlayfairDisplay-Regular",
            "PlayfairDisplay-Bold",
            "PlayfairDisplay-Black",
            "SecularOne-Regular",
            "Ubuntu-Regular",
            "Ubuntu-Bold"
        ]
    }
    
    private func fontButton(_ font: String) -> some View {
        let isSelected = customTheme.fontName == font
        
        return Button(action: {
            customTheme.fontName = font
        }) {
            VStack(spacing: 8) {
                Text("Aa")
                    .font(font == "SF Pro" ? .system(size: 32, weight: .bold) : .custom(font, size: 32))
                    .foregroundColor(isSelected ? customTheme.accentColor.color : .white)
                
                Text(fontDisplayName(font))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? customTheme.accentColor.color : Color.white.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
    }
    
    private func fontDisplayName(_ font: String) -> String {
        if font == "SF Pro" { return "SF Pro" }
        return font.replacingOccurrences(of: "-", with: " ")
    }
    
    
    private var effectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "EFFECTS")
            
            VStack(spacing: 12) {
                sliderRow(
                    title: "Glow Intensity",
                    value: $customTheme.glowIntensity,
                    range: 0...1
                )
                
                Toggle(isOn: $customTheme.shadowEnabled) {
                    Text("Shadows")
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .foregroundColor(.white)
                }
                .tint(customTheme.accentColor.color)
                
                Toggle(isOn: $customTheme.particlesEnabled) {
                    Text("Particles")
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .foregroundColor(.white)
                }
                .tint(customTheme.accentColor.color)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    
    private var gameplaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "GAMEPLAY")
            
            VStack(spacing: 12) {
                HStack {
                    Text("Proficiency Bonus")
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Stepper("\(customTheme.proficiencyBonus >= 0 ? "+" : "")\(customTheme.proficiencyBonus)", 
                            value: $customTheme.proficiencyBonus, 
                            in: -10...10)
                        .font(.custom("PlayfairDisplay-Bold", size: 16))
                        .foregroundColor(customTheme.accentColor.color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "PREVIEW")
            
            ZStack {
                customTheme.backgroundColor.color
                
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    customTheme.diceBorderColor.color.opacity(0.8),
                                    customTheme.diceBorderColor.color.opacity(0.3),
                                    customTheme.diceBorderColor.color.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: customTheme.diceBorderColor.color.opacity(0.5), radius: 10)
                    
                    Text("D20")
                        .font(.custom("PlayfairDisplay-Black", size: 18))
                        .foregroundColor(customTheme.accentColor.color)
                }
                .padding(40)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    
    private var buttonsSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                themeManager.applyTheme(customTheme)
                dismiss()
            }) {
                Text("APPLY")
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(customTheme.accentColor.color)
                    )
            }
            
            Button(action: {
                showSaveAlert = true
            }) {
                Text("SAVE")
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green)
                    )
            }
        }
        .padding(.top, 20)
    }
    
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.custom("PlayfairDisplay-Bold", size: 14))
            .foregroundColor(.white.opacity(0.7))
            .tracking(2)
    }
    
    private func colorButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.2f", value.wrappedValue))
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(customTheme.accentColor.color)
            }
            
            Slider(value: value, in: range)
                .tint(customTheme.accentColor.color)
        }
    }
    
    private func bindingForColorType(_ type: ColorPickerType) -> Binding<Color> {
        switch type {
        case .diceFace:
            return Binding(
                get: { customTheme.diceFaceColor.color },
                set: { customTheme.diceFaceColor = CodableColor(color: $0) }
            )
        case .diceBorder:
            return Binding(
                get: { customTheme.diceBorderColor.color },
                set: { customTheme.diceBorderColor = CodableColor(color: $0) }
            )
        case .diceNumber:
            return Binding(
                get: { customTheme.diceNumberColor.color },
                set: { customTheme.diceNumberColor = CodableColor(color: $0) }
            )
        case .background:
            return Binding(
                get: { customTheme.backgroundColor.color },
                set: { customTheme.backgroundColor = CodableColor(color: $0) }
            )
        case .accent:
            return Binding(
                get: { customTheme.accentColor.color },
                set: { customTheme.accentColor = CodableColor(color: $0) }
            )
        }
    }
    
    private func titleForColorType(_ type: ColorPickerType) -> String {
        switch type {
        case .diceFace: return "Dice Face"
        case .diceBorder: return "Dice Border"
        case .diceNumber: return "Numbers"
        case .background: return "Background"
        case .accent: return "Accent"
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


struct ColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: Color
    let title: String
    
    var body: some View {
        NavigationView {
            VStack {
                ColorPicker("Choose Color", selection: $selectedColor, supportsOpacity: true)
                    .padding()
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.custom("PlayfairDisplay-Bold", size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#FFD700")!)
                        )
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}


extension ThemeCustomizerView.ColorPickerType: Identifiable {
    var id: String {
        switch self {
        case .diceFace: return "diceFace"
        case .diceBorder: return "diceBorder"
        case .diceNumber: return "diceNumber"
        case .background: return "background"
        case .accent: return "accent"
        }
    }
}

#Preview {
    ThemeCustomizerView()
}
