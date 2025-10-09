//
//  RollButtonView.swift
//  Nano04DnDice
//
//  Componente - Botão de rolar COMPACTO
//

import SwiftUI

struct RollButtonView: View {
    let diceType: DiceType
    let rollMode: RollMode
    let isRolling: Bool
    let accentColor: Color
    let onRoll: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            if rollMode != .normal {
                Text(rollMode == .blessed ? "🙏 BLESSED" : "👿 CURSED")
                    .font(.custom("PlayfairDisplay-Bold", size: 10))
                    .foregroundColor(rollMode == .blessed ? .green : .red)
            }
            
            ActionButton(
                title: "ROLL \(diceType.shortName)",
                accentColor: accentColor,
                disabled: isRolling,
                action: onRoll
            )
        }
    }
}

// MARK: - Action Button Component

struct ActionButton: View {
    let title: String
    let accentColor: Color
    var disabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("PlayfairDisplay-Bold", size: 14))
                .foregroundColor(.black)
                .tracking(1)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: disabled ?
                                    [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] :
                                    [accentColor, accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: disabled ? .clear : accentColor.opacity(0.6), radius: 6)
                )
        }
        .disabled(disabled)
        .scaleEffect(disabled ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: disabled)
    }
}
