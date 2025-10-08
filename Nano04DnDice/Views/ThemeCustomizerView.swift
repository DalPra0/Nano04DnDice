//
//  ThemeCustomizerView.swift
//  Nano04DnDice
//
//  Tela de customização visual completa
//

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
                        // Header
                        headerView
                        
                        // Nome do Tema
                        themeNameSection
                        
                        // Cores do Dado
                        diceColorsSection
                        
                        // Cores do App
                        appColorsSection
                        
                        // Textura
                        textureSection
                        
                        // Efeitos
                        effectsSection
                        
                        // Preview
                        previewSection
                        
                        // Buttons
                        buttonsSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Customizar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FFD700"))
                }
            }
            .alert("Salvar Tema", isPresented: $showSaveAlert) {
                TextField("Nome do Tema", text: $themeName)
                Button("Cancelar", role: .cancel) {}
                Button("Salvar") {
                    saveTheme()
                }
            } message: {
                Text("Digite um nome para seu tema customizado")
            }
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("🎨")
                .font(.system(size: 60))
            
            Text("Crie seu Tema")
                .font(.custom("PlayfairDisplay-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Personalize cores, texturas e efeitos")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Theme Name
    
    private var themeNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "NOME DO TEMA")
            
            TextField("Nome do Tema", text: $themeName)
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
    
    // MARK: - Dice Colors
    
    private var diceColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "CORES DO DADO")
            
            colorButton(
                title: "Face do Dado",
                color: customTheme.diceFaceColor.color,
                action: { showColorPicker = .diceFace }
            )
            
            colorButton(
                title: "Borda do Dado",
                color: customTheme.diceBorderColor.color,
                action: { showColorPicker = .diceBorder }
            )
            
            colorButton(
                title: "Números",
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
    
    // MARK: - App Colors
    
    private var appColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "CORES DO APP")
            
            colorButton(
                title: "Fundo",
                color: customTheme.backgroundColor.color,
                action: { showColorPicker = .background }
            )
            
            colorButton(
                title: "Destaque (Botões/Bordas)",
                color: customTheme.accentColor.color,
                action: { showColorPicker = .accent }
            )
        }
    }
    
    // MARK: - Texture
    
    private var textureSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "TEXTURA DO DADO")
            
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
        case .standard: return Text("🎲")
        case .metallic: return Text("⚙️")
        case .wooden: return Text("🪵")
        case .stone: return Text("🗿")
        case .crystal: return Text("💎")
        }
    }
    
    // MARK: - Effects
    
    private var effectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "EFEITOS")
            
            VStack(spacing: 12) {
                sliderRow(
                    title: "Intensidade do Brilho",
                    value: $customTheme.glowIntensity,
                    range: 0...1
                )
                
                Toggle(isOn: $customTheme.shadowEnabled) {
                    Text("Sombras")
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .foregroundColor(.white)
                }
                .tint(customTheme.accentColor.color)
                
                Toggle(isOn: $customTheme.particlesEnabled) {
                    Text("Partículas")
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
    
    // MARK: - Preview
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "PREVIEW")
            
            ZStack {
                customTheme.backgroundColor.color
                
                VStack(spacing: 16) {
                    // Preview Dice
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
    
    // MARK: - Buttons
    
    private var buttonsSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                themeManager.applyTheme(customTheme)
                dismiss()
            }) {
                Text("APLICAR")
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
                Text("SALVAR")
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
    
    // MARK: - Helpers
    
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
        case .diceFace: return "Face do Dado"
        case .diceBorder: return "Borda do Dado"
        case .diceNumber: return "Números"
        case .background: return "Fundo"
        case .accent: return "Destaque"
        }
    }
    
    private func saveTheme() {
        var themeToSave = customTheme
        themeToSave.name = themeName.isEmpty ? "Tema Customizado" : themeName
        themeManager.saveCustomTheme(themeToSave)
        themeManager.applyTheme(themeToSave)
        dismiss()
    }
}

// MARK: - Color Picker Sheet

struct ColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: Color
    let title: String
    
    var body: some View {
        NavigationView {
            VStack {
                ColorPicker("Escolha a Cor", selection: $selectedColor, supportsOpacity: true)
                    .padding()
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Concluído")
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
    }
}

// MARK: - Extension

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
