
import SwiftUI

struct DiceSelectorView: View {
    let selectedDiceType: DiceType
    let accentColor: Color
    let onSelectDice: (DiceType) -> Void
    let onShowCustomDice: () -> Void
    let onShowMultipleDice: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach([DiceType.d4, .d6, .d8, .d10, .d12, .d20], id: \.self) { dice in
                    diceButton(dice)
                }
            }
            
            HStack(spacing: 8) {
                customDiceButton
                multipleDiceButton
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    
    private func diceButton(_ dice: DiceType) -> some View {
        Button(action: { onSelectDice(dice) }) {
            Text(dice.shortName)
                .font(.custom("PlayfairDisplay-Bold", size: 18))
                .foregroundColor(selectedDiceType == dice ? .black : accentColor)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selectedDiceType == dice ? accentColor : Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                        )
                )
        }
    }
    
    private var customDiceButton: some View {
        Button(action: onShowCustomDice) {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14))
                Text(selectedDiceType.isCustom ? "D\(selectedDiceType.sides)" : "D?")
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
            }
            .foregroundColor(selectedDiceType.isCustom ? .black : accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedDiceType.isCustom ? accentColor : Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                    )
            )
        }
    }
    
    private var multipleDiceButton: some View {
        Button(action: onShowMultipleDice) {
            HStack(spacing: 6) {
                Image(systemName: "square.on.square")
                    .font(.system(size: 14))
                Text("×D")
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
            }
            .foregroundColor(accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                    )
            )
        }
    }
}
