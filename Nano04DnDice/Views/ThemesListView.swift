
import SwiftUI

struct ThemesListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var showDeleteAlert = false
    @State private var themeToDelete: DiceCustomization?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                        
                        sectionHeader(title: "PRESET THEMES", icon: "star.fill")
                        
                        ForEach(PresetThemes.allThemes) { theme in
                            ThemeCardView(theme: theme, isCurrentTheme: theme.id == themeManager.currentTheme.id) {
                                themeManager.applyTheme(theme)
                                dismiss()
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.vertical, 10)
                        
                        sectionHeader(title: "MY THEMES", icon: "paintbrush.fill")
                        
                        let customThemes = themeManager.savedThemes.filter { theme in
                            !PresetThemes.allThemes.contains(where: { $0.name == theme.name })
                        }
                        
                        if customThemes.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(customThemes) { theme in
                                ThemeCardView(
                                    theme: theme,
                                    isCurrentTheme: theme.id == themeManager.currentTheme.id,
                                    showDeleteButton: true,
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
                    .padding(20)
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FFD700"))
                }
            }
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
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    
    private var headerView: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {  // 8pt
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 60))
            
            Text("Choose your Theme")
                .font(.custom("PlayfairDisplay-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Select a theme or create your own")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(.bottom, DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Escolha seu tema. Selecione um tema ou crie o seu próprio")
    }
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#FFD700"))
            
            Text(title)
                .font(.custom("PlayfairDisplay-Bold", size: 18))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isHeader)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "paintpalette")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.textDisabled)
            
            Text("No custom themes yet")
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text("Use 'CUSTOMIZE' to create your first theme!")
                .font(.custom("PlayfairDisplay-Regular", size: 12))
                .foregroundColor(DesignSystem.Colors.textDisabled)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                        .fill(Color.white.opacity(0.05))
                )
        )
        .padding(.horizontal, DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
    }
    
}


struct ThemeCardView: View {
    let theme: DiceCustomization
    let isCurrentTheme: Bool
    var showDeleteButton: Bool = false
    let onSelect: () -> Void
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                colorPreview
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(theme.name)
                            .font(.custom("PlayfairDisplay-Bold", size: 18))
                            .foregroundColor(.white)
                        
                        if isCurrentTheme {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                    }
                    
                    Text(theme.diceTexture.rawValue.capitalized)
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                
                if showDeleteButton {
                    Button(action: {
                        onDelete?()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(DesignSystem.Spacing.xs)  // 8pt
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Deletar tema \(theme.name)")
                    .accessibilityHint("Toque para excluir este tema")
                }
            }
            .padding(DesignSystem.Spacing.md)  // 16pt
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.backgroundTertiary,
                                DesignSystem.Colors.backgroundSecondary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                            .stroke(
                                isCurrentTheme ? theme.accentColor.color : Color.white.opacity(0.2),  // Mantém relativo ao tema
                                lineWidth: isCurrentTheme ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.name). \(theme.diceTexture.rawValue)\(isCurrentTheme ? ". Selecionado" : "")")
        .accessibilityHint(isCurrentTheme ? "" : "Toque para aplicar este tema")
        .accessibilityAddTraits(isCurrentTheme ? [.isButton, .isSelected] : .isButton)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private var colorPreview: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall)
                .fill(theme.diceFaceColor.color)
                .frame(width: 20, height: 50)
            
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall)
                .fill(theme.diceBorderColor.color)
                .frame(width: 20, height: 50)
            
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall)
                .fill(theme.accentColor.color)
                .frame(width: 20, height: 50)
        }
    }
}

#Preview {
    ThemesListView()
}
