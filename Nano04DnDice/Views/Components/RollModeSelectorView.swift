//
//  RollModeSelectorView.swift
//

import SwiftUI

struct RollModeSelectorView: View {
    let selectedMode: RollMode
    let accentColor: Color
    let backgroundColor: Color
    let onSelectMode: (RollMode) -> Void
    
    @State private var isExpanded: Bool = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                if reduceMotion {
                    isExpanded.toggle()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }
            }) {
                HStack {
                    Text("ROLL MODE")
                        .font(.custom("PlayfairDisplay-Bold", size: 14))
                        .foregroundColor(backgroundColor.contrastText)
                    
                    Spacer()
                    
                    Text(selectedMode.displayName)
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(accentColor)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(accentColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                        .fill(DesignSystem.Colors.backgroundSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                                .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                        )
                )
            }
            .accessibilityLabel("Modo de rolagem: \(selectedMode.displayName)")
            .accessibilityHint(isExpanded ? "Toque para fechar opções" : "Toque para ver opções de modo")
            .accessibilityAddTraits(.isButton)
            
            if isExpanded {
                VStack(spacing: 6) {
                    modeButton(.normal, icon: "circle", label: "Normal")
                    modeButton(.blessed, icon: "arrow.up.circle.fill", label: "Blessed")
                    modeButton(.cursed, icon: "arrow.down.circle.fill", label: "Cursed")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                        .fill(DesignSystem.Colors.backgroundOverlay)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    
    private func modeButton(_ mode: RollMode, icon: String, label: String) -> some View {
        Button(action: { 
            onSelectMode(mode)
            if reduceMotion {
                isExpanded = false
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded = false
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(selectedMode == mode ? .black : accentColor)
                
                Text(label)
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
                    .foregroundColor(selectedMode == mode ? .black : accentColor)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall)
                    .fill(selectedMode == mode ? accentColor : Color.clear)
            )
        }
        .accessibilityLabel(accessibilityLabelForMode(mode))
        .accessibilityHint(accessibilityHintForMode(mode))
        .accessibilityAddTraits(selectedMode == mode ? [.isButton, .isSelected] : .isButton)
    }
    
    private func accessibilityLabelForMode(_ mode: RollMode) -> String {
        switch mode {
        case .normal: return "Modo normal"
        case .blessed: return "Modo abençoado"
        case .cursed: return "Modo amaldiçoado"
        }
    }
    
    private func accessibilityHintForMode(_ mode: RollMode) -> String {
        switch mode {
        case .normal: return "Rola um dado normalmente"
        case .blessed: return "Rola dois dados e usa o maior resultado"
        case .cursed: return "Rola dois dados e usa o menor resultado"
        }
    }
}
