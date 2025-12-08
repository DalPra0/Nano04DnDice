
import SwiftUI

struct DiceSelectorView: View {
    let selectedDiceType: DiceType
    let accentColor: Color
    let onSelectDice: (DiceType) -> Void
    let onShowCustomDice: () -> Void
    let onShowMultipleDice: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {  // 8pt
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: DesignSystem.Spacing.xs) {  // 8pt
                ForEach([DiceType.d4, .d6, .d8, .d10, .d12, .d20], id: \.self) { dice in
                    diceButton(dice)
                }
            }
            
            HStack(spacing: DesignSystem.Spacing.xs) {  // 8pt
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
        .accessibilityLabel("Dado de \(dice.sides) lados")
        .accessibilityHint(selectedDiceType == dice ? "Selecionado" : "Toque para selecionar")
        .accessibilityAddTraits(selectedDiceType == dice ? [.isButton, .isSelected] : .isButton)
    }
    
    private var customDiceButton: some View {
        Button(action: onShowCustomDice) {
            HStack(spacing: DesignSystem.Spacing.xxs + 2) {  // 6pt
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14))
                Text(selectedDiceType.isCustom ? "D\(selectedDiceType.sides)" : "D?")
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
            }
            .foregroundColor(selectedDiceType.isCustom ? .black : accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                    .fill(selectedDiceType.isCustom ? accentColor : DesignSystem.Colors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                            .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                    )
            )
        }
        .accessibilityLabel(selectedDiceType.isCustom ? "Dado customizado de \(selectedDiceType.sides) lados" : "Dado customizado")
        .accessibilityHint(selectedDiceType.isCustom ? "Selecionado. Toque para editar" : "Toque para configurar dado customizado")
        .accessibilityAddTraits(selectedDiceType.isCustom ? [.isButton, .isSelected] : .isButton)
    }
    
    private var multipleDiceButton: some View {
        Button(action: onShowMultipleDice) {
            HStack(spacing: DesignSystem.Spacing.xxs + 2) {  // 6pt
                Image(systemName: "square.on.square")
                    .font(.system(size: 14))
                Text("×D")
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
            }
            .foregroundColor(accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                    .fill(DesignSystem.Colors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                            .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                    )
            )
        }
        .accessibilityLabel("Múltiplos dados")
        .accessibilityHint("Toque para rolar vários dados ao mesmo tempo")
    }
}
