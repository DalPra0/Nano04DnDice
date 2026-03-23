
import SwiftUI

struct TopButtonsView: View {
    @EnvironmentObject private var subManager: SubscriptionManager
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
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
                    .zIndex(998)
            }
            
            VStack {
                HStack(spacing: 16) {
                    // Quick Action: Themes
                    Button(action: onShowThemes) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(accentColor)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(DesignSystem.Colors.backgroundOverlay))
                    }
                    
                    // Quick Action: AR (Always Unlocked)
                    Button(action: {
                        onShowAR()
                    }) {
                        Image(systemName: "arkit")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(accentColor)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(DesignSystem.Colors.backgroundOverlay))
                    }
                    
                    Spacer()
                    
                    // Main Menu Button
                    VStack(alignment: .trailing, spacing: 0) {
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            if reduceMotion {
                                isMenuOpen.toggle()
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isMenuOpen.toggle()
                                }
                            }
                        }) {
                            Image(systemName: isMenuOpen ? "xmark" : "line.3.horizontal")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(accentColor)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(DesignSystem.Colors.backgroundOverlay))
                        }
                        
                        if isMenuOpen {
                            VStack(alignment: .trailing, spacing: 10) {
                                MenuButton(icon: "person.text.rectangle.fill", title: "menu_character", accentColor: accentColor) { performAction(onShowCharacterSheet) }
                                MenuButton(icon: "book.fill", title: "menu_campaign", accentColor: accentColor) { performAction(onShowCampaignManager) }
                                MenuButton(icon: "chart.bar.fill", title: "menu_stats", accentColor: accentColor) { performAction(onShowDetailedStats) }
                                MenuButton(icon: "clock.arrow.circlepath", title: "menu_history", accentColor: accentColor) { performAction(onShowHistory) }
                                MenuButton(icon: "speaker.wave.3.fill", title: "menu_audio", accentColor: accentColor) { performAction(onShowAudioSettings) }
                                MenuButton(icon: "pencil.and.outline", title: "menu_customize", accentColor: accentColor) { performAction(onShowCustomizer) }
                            }
                            .padding(.top, 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
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
                Text(LocalizedStringKey(title))
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
        .accessibilityLabel(LocalizedStringKey(title))
        .enableInjection()
    }
}
