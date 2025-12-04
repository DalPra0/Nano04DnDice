
import SwiftUI

struct TopButtonsView: View {
    let accentColor: Color
    let onShowThemes: () -> Void
    let onShowCustomizer: () -> Void
    let onShowAR: () -> Void
    let onShowHistory: () -> Void
    let onShowDetailedStats: () -> Void
    let onShowAudioSettings: () -> Void
    
    @State private var isMenuOpen = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
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
                            if reduceMotion {
                                isMenuOpen.toggle()
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isMenuOpen.toggle()
                                }
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(accentColor)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .accessibilityLabel(isMenuOpen ? "Fechar menu" : "Abrir menu")
                        .accessibilityHint("Menu com opções de AR, temas e customização")
                        .accessibilityAddTraits(.isButton)
                        
                        if isMenuOpen {
                            VStack(alignment: .trailing, spacing: 12) {
                                MenuButton(
                                    icon: "speaker.wave.3.fill",
                                    title: "AUDIO",
                                    accentColor: accentColor,
                                    action: {
                                        if reduceMotion {
                                            isMenuOpen = false
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isMenuOpen = false
                                            }
                                        }
                                        onShowAudioSettings()
                                    }
                                )
                                
                                MenuButton(
                                    icon: "chart.bar.fill",
                                    title: "STATS",
                                    accentColor: accentColor,
                                    action: {
                                        if reduceMotion {
                                            isMenuOpen = false
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isMenuOpen = false
                                            }
                                        }
                                        onShowDetailedStats()
                                    }
                                )
                                
                                MenuButton(
                                    icon: "clock.arrow.circlepath",
                                    title: "HISTORY",
                                    accentColor: accentColor,
                                    action: {
                                        if reduceMotion {
                                            isMenuOpen = false
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isMenuOpen = false
                                            }
                                        }
                                        onShowHistory()
                                    }
                                )
                                
                                MenuButton(
                                    icon: "arkit",
                                    title: "AR DICE",
                                    accentColor: accentColor,
                                    action: {
                                        if reduceMotion {
                                            isMenuOpen = false
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isMenuOpen = false
                                            }
                                        }
                                        onShowAR()
                                    }
                                )
                                
                                MenuButton(
                                    icon: "rectangle.stack.fill",
                                    title: "THEMES",
                                    accentColor: accentColor,
                                    action: {
                                        if reduceMotion {
                                            isMenuOpen = false
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isMenuOpen = false
                                            }
                                        }
                                        onShowThemes()
                                    }
                                )
                                
                                MenuButton(
                                    icon: "paintpalette.fill",
                                    title: "CUSTOMIZE",
                                    accentColor: accentColor,
                                    action: {
                                        if reduceMotion {
                                            isMenuOpen = false
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isMenuOpen = false
                                            }
                                        }
                                        onShowCustomizer()
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentColor)
            )
        }
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(accessibilityHintText)
        .enableInjection()
    }
    
    private var accessibilityLabelText: String {
        switch title {
        case "HISTORY": return "Histórico de rolagens"
        case "AR DICE": return "Dado em realidade aumentada"
        case "THEMES": return "Temas"
        case "CUSTOMIZE": return "Customizar tema"
        default: return title
        }
    }
    
    private var accessibilityHintText: String {
        switch title {
        case "HISTORY": return "Visualiza estatísticas e histórico de rolagens anteriores"
        case "AR DICE": return "Abre visualização AR para jogar dado em 3D"
        case "THEMES": return "Escolhe um tema pré-definido"
        case "CUSTOMIZE": return "Cria seu próprio tema personalizado"
        default: return ""
        }
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
