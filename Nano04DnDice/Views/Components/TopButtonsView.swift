
import SwiftUI

struct TopButtonsView: View {
    let accentColor: Color
    let onShowThemes: () -> Void
    let onShowCustomizer: () -> Void
    let onShowAR: () -> Void
    let onShowHistory: () -> Void
    let onShowDetailedStats: () -> Void
    let onShowAudioSettings: () -> Void
    let onShowCampaignManager: () -> Void
    let onShowCharacterSheet: () -> Void
    
    @State private var isMenuOpen = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // Helper to close menu with proper animation
    private func closeMenu() {
        if reduceMotion {
            isMenuOpen = false
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isMenuOpen = false
            }
        }
    }
    
    private func performAction(_ action: @escaping () -> Void) {
        closeMenu()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            action()
        }
    }
    
    var body: some View {
        ZStack {
            if isMenuOpen {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isMenuOpen = false
                        }
                    }
                    .zIndex(998)
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Button(action: {
                            print("🔘 Menu button tapped - current state: \(isMenuOpen)")
                            if reduceMotion {
                                isMenuOpen.toggle()
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isMenuOpen.toggle()
                                }
                            }
                            print("🔘 Menu button - new state: \(isMenuOpen)")
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(accentColor)
                                .frame(width: DesignSystem.ButtonSize.medium.height, height: DesignSystem.ButtonSize.medium.height)
                                .background(
                                    Circle()
                                        .fill(DesignSystem.Colors.backgroundOverlay)
                                )
                        }
                        .accessibilityLabel(isMenuOpen ? "Fechar menu" : "Abrir menu")
                        .accessibilityHint("Menu com opções de AR, temas e customização")
                        .accessibilityAddTraits(.isButton)
                        
                        if isMenuOpen {
                            VStack(alignment: .trailing, spacing: 12) {
                                MenuButton(
                                    icon: "person.text.rectangle.fill",
                                    title: "CHARACTER",
                                    accentColor: accentColor,
                                    action: {
                                        print("🎭 CHARACTER button tapped")
                                        performAction {
                                            onShowCharacterSheet()
                                            print("🎭 CHARACTER - callback executed")
                                        }
                                    }
                                )
                                
                                MenuButton(
                                    icon: "book.fill",
                                    title: "CAMPAIGN",
                                    accentColor: accentColor,
                                    action: {
                                        performAction {
                                            onShowCampaignManager()
                                        }
                                    }
                                )
                                
                                MenuButton(
                                    icon: "speaker.wave.3.fill",
                                    title: "AUDIO",
                                    accentColor: accentColor,
                                    action: {
                                        performAction {
                                            onShowAudioSettings()
                                        }
                                    }
                                )
                                
                                MenuButton(
                                    icon: "chart.bar.fill",
                                    title: "STATS",
                                    accentColor: accentColor,
                                    action: {
                                        performAction {
                                            onShowDetailedStats()
                                        }
                                    }
                                )
                                
                                MenuButton(
                                    icon: "clock.arrow.circlepath",
                                    title: "HISTORY",
                                    accentColor: accentColor,
                                    action: {
                                        performAction {
                                            onShowHistory()
                                        }
                                    }
                                )
                                
                                MenuButton(
                                    icon: "arkit",
                                    title: "AR DICE",
                                    accentColor: accentColor,
                                    action: {
                                        performAction {
                                            onShowAR()
                                        }
                                    }
                                )
                                
                                MenuButton(
                                    icon: "rectangle.stack.fill",
                                    title: "THEMES",
                                    accentColor: accentColor,
                                    action: {
                                        performAction {
                                            onShowThemes()
                                        }
                                    }
                                )
                                
                                MenuButton(
                                    icon: "paintpalette.fill",
                                    title: "CUSTOMIZE",
                                    accentColor: accentColor,
                                    action: {
                                        performAction {
                                            onShowCustomizer()
                                        }
                                    }
                                )
                            }
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            .zIndex(1001)
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}


struct MenuButton: View {
    let icon: String
    let title: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                    .fill(accentColor)
            )
        }
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(accessibilityHintText)
        .enableInjection()
    }
    
    private var accessibilityLabelText: String {
        switch title {
        case "CHARACTER": return "Ficha de personagem"
        case "CAMPAIGN": return "Gerenciador de campanha"
        case "HISTORY": return "Histórico de rolagens"
        case "AR DICE": return "Dado em realidade aumentada"
        case "THEMES": return "Temas"
        case "CUSTOMIZE": return "Customizar tema"
        case "AUDIO": return "Configurações de áudio"
        case "STATS": return "Estatísticas detalhadas"
        default: return title
        }
    }
    
    private var accessibilityHintText: String {
        switch title {
        case "CHARACTER": return "Visualiza e edita ficha do personagem"
        case "CAMPAIGN": return "Gerencia NPCs, inventário e campanhas"
        case "HISTORY": return "Visualiza estatísticas e histórico de rolagens anteriores"
        case "AR DICE": return "Abre visualização AR para jogar dado em 3D"
        case "THEMES": return "Escolhe um tema pré-definido"
        case "CUSTOMIZE": return "Cria seu próprio tema personalizado"
        case "AUDIO": return "Personaliza efeitos sonoros"
        case "STATS": return "Visualiza estatísticas avançadas e análises"
        default: return ""
        }
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
