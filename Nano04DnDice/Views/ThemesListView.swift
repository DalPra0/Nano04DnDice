
import SwiftUI

struct ThemesListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var showDeleteAlert = false
    @State private var themeToDelete: DiceCustomization?
    
    private var accentColor: Color {
        themeManager.currentTheme.accentColor.color
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
                        
                        // Preset Themes
                        VStack(alignment: .leading, spacing: 20) {
                            sectionLabel("LEGENDARY PRESETS", icon: "crown.fill")
                            
                            VStack(spacing: 12) {
                                ForEach(PresetThemes.allThemes) { theme in
                                    ThemeGalleryCard(
                                        theme: theme, 
                                        isCurrent: theme.id == themeManager.currentTheme.id,
                                        onSelect: {
                                            themeManager.applyTheme(theme)
                                            dismiss()
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Custom Themes
                        let customThemes = themeManager.savedThemes.filter { theme in
                            !PresetThemes.allThemes.contains(where: { $0.name == theme.name })
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            sectionLabel("YOUR FORGE", icon: "hammer.fill")
                            
                            if customThemes.isEmpty {
                                emptyStateView
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(customThemes) { theme in
                                        ThemeGalleryCard(
                                            theme: theme,
                                            isCurrent: theme.id == themeManager.currentTheme.id,
                                            showDelete: true,
                                            onSelect: {
                                                themeManager.applyTheme(theme)
                                                dismiss()
                                            },
                                            onDelete: {
                                                themeToDelete = theme
                                                showDeleteAlert = true
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Delete Theme", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let theme = themeToDelete {
                    themeManager.deleteTheme(theme)
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(themeToDelete?.name ?? "")'?")
        }
    }
    
    private var customHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                
                Spacer()
                
                Text("THEME GALLERY")
                    .font(.custom("PlayfairDisplay-Black", size: 18))
                    .foregroundColor(.white)
                    .tracking(2)
                
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
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 50))
                .foregroundColor(accentColor)
                .shadow(color: accentColor.opacity(0.5), radius: 10)
            
            Text("Choose your Aura")
                .font(.custom("PlayfairDisplay-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Select a preset or visit the forge to create")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
    }
    
    private func sectionLabel(_ text: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.custom("PlayfairDisplay-Bold", size: 12))
                .tracking(3)
            Spacer()
        }
        .foregroundColor(accentColor.opacity(0.8))
        .padding(.leading, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 40))
                .foregroundColor(accentColor.opacity(0.3))
            
            Text("No custom auras forged yet")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct ThemeGalleryCard: View {
    let theme: DiceCustomization
    let isCurrent: Bool
    var showDelete: Bool = false
    let onSelect: () -> Void
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Mini Dice Preview
                ZStack {
                    Circle()
                        .fill(theme.backgroundColor.color)
                        .frame(width: 50, height: 50)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.diceFaceColor.color)
                        .frame(width: 28, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.diceBorderColor.color, lineWidth: 2)
                        )
                        .rotationEffect(.degrees(45))
                    
                    Text("20")
                        .font(.custom("PlayfairDisplay-Black", size: 10))
                        .foregroundColor(theme.accentColor.color)
                }
                .shadow(color: theme.accentColor.color.opacity(0.4), radius: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(theme.name)
                            .font(.custom("PlayfairDisplay-Bold", size: 18))
                            .foregroundColor(.white)
                        
                        if isCurrent {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(theme.accentColor.color)
                        }
                    }
                    
                    Text(theme.diceTexture.rawValue.capitalized)
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                
                Spacer()
                
                if showDelete {
                    Button(action: { onDelete?() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.7))
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                } else if isCurrent {
                    Text("ACTIVE")
                        .font(.custom("PlayfairDisplay-Black", size: 10))
                        .foregroundColor(theme.accentColor.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.accentColor.color.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isCurrent ? theme.accentColor.color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: isCurrent ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
