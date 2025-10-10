//
//  DiceResultView.swift
//  Nano04DnDice
//
//  Componente - Resultado COMPACTO
//

import SwiftUI

struct DiceResultView: View {
    let result: Int
    let secondResult: Int?
    let rollMode: RollMode
    let diceSides: Int
    let accentColor: Color
    let backgroundColor: Color
    let shadowEnabled: Bool
    let glowIntensity: Double
    let proficiencyBonus: Int
    let onContinue: () -> Void
    
    private var baseRoll: Int {
        result - proficiencyBonus
    }
    
    private var isCritical: Bool {
        baseRoll == diceSides
    }
    
    private var isFumble: Bool {
        baseRoll == 1
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Roll Mode Info
            if rollMode != .normal, let second = secondResult {
                VStack(spacing: 4) {
                    Text(rollMode == .blessed ? "BLESSED" : "CURSED")
                        .font(.custom("PlayfairDisplay-Bold", size: 14))
                        .foregroundColor(rollMode == .blessed ? .green : .red)
                    
                    HStack(spacing: 8) {
                        Text("[\(second)]")
                            .font(.custom("PlayfairDisplay-Regular", size: 18))
                            .foregroundColor(backgroundColor.contrastTextTertiary)
                            .strikethrough()
                        
                        Text("[\(baseRoll)]")
                            .font(.custom("PlayfairDisplay-Bold", size: 20))
                            .foregroundColor(accentColor)
                    }
                }
            }
            
            // Result Number with Bonus
            if proficiencyBonus != 0 {
                HStack(spacing: 4) {
                    Text("\(baseRoll)")
                        .font(.custom("PlayfairDisplay-Black", size: 32))
                        .foregroundColor(accentColor)
                    
                    Text("\(proficiencyBonus >= 0 ? "+" : "")\(proficiencyBonus)")
                        .font(.custom("PlayfairDisplay-Bold", size: 24))
                        .foregroundColor(backgroundColor.contrastTextSecondary)
                    
                    Text("=")
                        .font(.custom("PlayfairDisplay-Regular", size: 24))
                        .foregroundColor(backgroundColor.contrastTextTertiary)
                    
                    Text("\(result)")
                        .font(.custom("PlayfairDisplay-Black", size: 40))
                        .foregroundColor(accentColor)
                }
            } else {
                Text("\(result)")
                    .font(.custom("PlayfairDisplay-Black", size: 48))
                    .foregroundColor(accentColor)
            }
            
            // Critical/Fumble Text
            if let text = resultText {
                Text(text)
                    .font(.custom("PlayfairDisplay-Black", size: 20))
                    .foregroundColor(resultColor)
            }
            
            // Continue Button
            ActionButton(
                title: "CONTINUE",
                accentColor: accentColor,
                shadowEnabled: shadowEnabled,
                glowIntensity: glowIntensity,
                action: onContinue
            )
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    // MARK: - Computed Properties
    
    private var resultText: String? {
        if isCritical {
            return "CRITICAL!"
        } else if isFumble {
            return "FUMBLE!"
        } else {
            return nil
        }
    }
    
    private var resultColor: Color {
        if isCritical {
            return .green
        } else if isFumble {
            return .red
        } else {
            return accentColor
        }
    }
}
