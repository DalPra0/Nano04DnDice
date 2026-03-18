
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
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle(LocalizedStringKey("cust_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("Cancel")) {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FFD700"))
                }
            }
            .alert(LocalizedStringKey("cust_save"), isPresented: $showSaveAlert) {
                TextField(LocalizedStringKey("cust_theme_name"), text: $themeName)
                Button(LocalizedStringKey("Cancel"), role: .cancel) {}
                Button(LocalizedStringKey("cust_save")) {
                    saveTheme()
                }
            } message: {
                Text("Enter a name for your custom theme")
            }
        }
        .sheet(isPresented: $subManager.showPaywall) {
            PaywallView(displayCloseButton: true)
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
            Text(LocalizedStringKey("cust_create_theme"))
                .font(.custom("PlayfairDisplay-Bold", size: 24))
                .foregroundColor(.white)
            Text(LocalizedStringKey("cust_subtitle"))
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(.bottom, 10)
    }
    
    private var themeNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "cust_theme_name")
            TextField(LocalizedStringKey("cust_theme_name"), text: $themeName)
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                        .fill(DesignSystem.Colors.backgroundOverlay)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                                .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
                        )
                )
        }
    }
    
    private var diceColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "cust_dice_colors")
            colorButton(title: "Dice Face", color: customTheme.diceFaceColor.color) { showColorPicker = .diceFace }
            colorButton(title: "Dice Border", color: customTheme.diceBorderColor.color) { showColorPicker = .diceBorder }
            colorButton(title: "Numbers", color: customTheme.diceNumberColor.color) { showColorPicker = .diceNumber }
        }
        .sheet(item: $showColorPicker) { type in
            ColorPickerSheet(selectedColor: bindingForColorType(type), title: titleForColorType(type))
        }
    }
    
    private var appColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "cust_app_colors")
            colorButton(title: "Background", color: customTheme.backgroundColor.color) { showColorPicker = .background }
            colorButton(title: "Accent", color: customTheme.accentColor.color) { showColorPicker = .accent }
        }
    }
    
    private var textureSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "cust_texture")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([DiceCustomization.DiceTexture.standard, .metallic, .wooden, .stone, .crystal], id: \.self) { texture in
                        textureButton(texture)
                    }
                }
            }
        }
    }
    
    private func textureButton(_ texture: DiceCustomization.DiceTexture) -> some View {
        let isPremium = texture != .standard
        let isLocked = isPremium && !subManager.isPro
        let isSelected = customTheme.diceTexture == texture
        
        return Button(action: {
            if isLocked {
                subManager.showPaywall = true
            } else {
                customTheme.diceTexture = texture
            }
        }) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    textureIcon(for: texture)
                        .font(.system(size: 30))
                        .foregroundColor(isSelected ? customTheme.accentColor.color : .white)
                    
                    if isLocked {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                            .offset(x: 4, y: -4)
                    }
                }
                Text(LocalizedStringKey("tex_\(texture.rawValue)"))
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                    .fill(DesignSystem.Colors.backgroundOverlay)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                            .stroke(isSelected ? customTheme.accentColor.color : DesignSystem.Colors.borderSubtle, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
    
    private func textureIcon(for texture: DiceCustomization.DiceTexture) -> some View {
        switch texture {
        case .standard: return Image(systemName: "square.fill")
        case .metallic: return Image(systemName: "bitcoinsign.circle.fill")
        case .wooden: return Image(systemName: "leaf.fill")
        case .stone: return Image(systemName: "mountain.2.fill")
        case .crystal: return Image(systemName: "diamond.fill")
        }
    }
    
    private var fontSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "cust_font")
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
        ["SF Pro", "BebasNeue-Regular", "MetalMania-Regular", "Pangolin-Regular", "PlayfairDisplay-Regular", "PlayfairDisplay-Bold", "PlayfairDisplay-Black", "SecularOne-Regular", "Ubuntu-Regular", "Ubuntu-Bold"]
    }
    
    private func fontButton(_ font: String) -> some View {
        let isSelected = customTheme.fontName == font
        return Button(action: { customTheme.fontName = font }) {
            VStack(spacing: 8) {
                Text("Aa").font(font == "SF Pro" ? .system(size: 32, weight: .bold) : .custom(font, size: 32))
                    .foregroundColor(isSelected ? customTheme.accentColor.color : .white)
                Text(font.replacingOccurrences(of: "-", with: " ")).font(.system(size: 10))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                    .fill(DesignSystem.Colors.backgroundOverlay)
                    .overlay(RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                        .stroke(isSelected ? customTheme.accentColor.color : DesignSystem.Colors.borderSubtle, lineWidth: isSelected ? 2 : 1))
            )
        }
    }
    
    private var effectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "cust_effects")
            VStack(spacing: 12) {
                sliderRow(title: "Glow Intensity", value: $customTheme.glowIntensity, range: 0...1)
                Toggle(isOn: $customTheme.shadowEnabled) {
                    Text("Shadows").font(.custom("PlayfairDisplay-Regular", size: 16)).foregroundColor(.white)
                }
                .tint(customTheme.accentColor.color)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium).fill(Color.white.opacity(0.1)))
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "cust_preview")
            ZStack {
                customTheme.backgroundColor.color
                DiceDisplayView(diceSize: 180, currentNumber: 20, isRolling: false, glowIntensity: customTheme.glowIntensity, diceBorderColor: customTheme.diceBorderColor.color, accentColor: customTheme.accentColor.color, diceSides: 20, theme: customTheme, onRollComplete: { _ in })
                    .scaleEffect(0.8)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge))
        }
    }
    
    private var buttonsSection: some View {
        HStack(spacing: 16) {
            Button(action: { themeManager.applyTheme(customTheme); dismiss() }) {
                Text(LocalizedStringKey("cust_apply")).font(.custom("PlayfairDisplay-Bold", size: 16)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding().background(RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge).fill(customTheme.accentColor.color))
            }
            Button(action: { showSaveAlert = true }) {
                Text(LocalizedStringKey("cust_save")).font(.custom("PlayfairDisplay-Bold", size: 16)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding().background(RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge).fill(Color.green))
            }
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        Text(LocalizedStringKey(title)).font(.custom("PlayfairDisplay-Bold", size: 14)).foregroundColor(.white.opacity(0.7)).tracking(2)
    }
    
    private func colorButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).font(.custom("PlayfairDisplay-Regular", size: 16)).foregroundColor(.white)
                Spacer()
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall).fill(color).frame(width: 40, height: 40)
            }
            .padding().background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
        }
    }
    
    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.custom("PlayfairDisplay-Regular", size: 16)).foregroundColor(.white)
                Spacer()
                Text(String(format: "%.2f", value.wrappedValue)).font(.custom("PlayfairDisplay-Bold", size: 14)).foregroundColor(customTheme.accentColor.color)
            }
            Slider(value: value, in: range).tint(customTheme.accentColor.color)
        }
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

struct ColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: Color
    let title: String
    var body: some View {
        NavigationView {
            VStack {
                ColorPicker("Choose Color", selection: $selectedColor, supportsOpacity: true).padding()
                Spacer()
                Button(action: { dismiss() }) {
                    Text("Done").font(.custom("PlayfairDisplay-Bold", size: 16)).foregroundColor(.black).frame(maxWidth: .infinity).padding().background(RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge).fill(Color(hex: "#FFD700")!))
                }
                .padding()
            }
            .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
        }
        .enableInjection()
    }
}
