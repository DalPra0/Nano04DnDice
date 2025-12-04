
import SwiftUI

struct RollButtonView: View {
    let diceType: DiceType
    let rollMode: RollMode
    let isRolling: Bool
    let accentColor: Color
    let shadowEnabled: Bool
    let glowIntensity: Double
    let onRoll: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            if rollMode != .normal {
                Text(rollMode == .blessed ? "BLESSED" : "CURSED")
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(rollMode == .blessed ? .green : .red)
            }
            
            ActionButton(
                title: "ROLL \(diceType.shortName)",
                accentColor: accentColor,
                shadowEnabled: shadowEnabled,
                glowIntensity: glowIntensity,
                disabled: isRolling,
                action: onRoll
            )
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}


struct ActionButton: View {
    let title: String
    let accentColor: Color
    let shadowEnabled: Bool
    let glowIntensity: Double
    var disabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.black)
                .tracking(1.5)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: disabled ?
                                    [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] :
                                    [accentColor, accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: (shadowEnabled && !disabled) ? accentColor.opacity(0.6 * glowIntensity) : .clear,
                            radius: shadowEnabled ? 10 : 0
                        )
                )
        }
        .disabled(disabled)
        .scaleEffect(disabled ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: disabled)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
