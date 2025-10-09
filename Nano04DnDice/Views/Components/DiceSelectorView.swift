//
//  DiceSelectorView.swift
//  Nano04DnDice
//
//  Componente - Grid COMPACTO
//

import SwiftUI

struct DiceSelectorView: View {
    let selectedDiceType: DiceType
    let accentColor: Color
    let onSelectDice: (DiceType) -> Void
    let onShowCustomDice: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            // Standard Dice
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach([DiceType.d4, .d6, .d8, .d10, .d12, .d20], id: \.self) { dice in
                    diceButton(dice)
                }
            }
            
            // Custom Dice Button
            customDiceButton
        }
    }
    
    // MARK: - Subviews
    
    private func diceButton(_ dice: DiceType) -> some View {
        Button(action: { onSelectDice(dice) }) {
            Text(dice.shortName)
                .font(.custom("PlayfairDisplay-Bold", size: 14))
                .foregroundColor(selectedDiceType == dice ? .black : accentColor)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(selectedDiceType == dice ? accentColor : Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                        )
                )
        }
    }
    
    private var customDiceButton: some View {
        Button(action: onShowCustomDice) {
            HStack(spacing: 4) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 11))
                Text(selectedDiceType.isCustom ? "D\(selectedDiceType.sides)" : "D?")
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
            }
            .foregroundColor(selectedDiceType.isCustom ? .black : accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(selectedDiceType.isCustom ? accentColor : Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                    )
            )
        }
    }
}
