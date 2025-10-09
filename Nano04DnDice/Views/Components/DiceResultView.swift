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
    let onContinue: () -> Void
    
    private var isCritical: Bool {
        result == diceSides
    }
    
    private var isFumble: Bool {
        result == 1
    }
    
    private var isSuccess: Bool {
        result >= (diceSides / 2)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Roll Mode Info
            if rollMode != .normal, let second = secondResult {
                VStack(spacing: 2) {
                    Text(rollMode == .blessed ? "🙏 BLESSED" : "👿 CURSED")
                        .font(.custom("PlayfairDisplay-Bold", size: 10))
                        .foregroundColor(rollMode == .blessed ? .green : .red)
                    
                    HStack(spacing: 4) {
                        Text("[\(second)]")
                            .font(.custom("PlayfairDisplay-Regular", size: 13))
                            .foregroundColor(.white.opacity(0.5))
                            .strikethrough()
                        
                        Text("[\(result)]")
                            .font(.custom("PlayfairDisplay-Bold", size: 15))
                            .foregroundColor(accentColor)
                    }
                }
            }
            
            // Result Text
            Text(resultText)
                .font(.custom("PlayfairDisplay-Black", size: 16))
                .foregroundColor(resultColor)
                .shadow(color: resultColor.opacity(0.5), radius: 6)
            
            // Continue Button
            ActionButton(
                title: "CONTINUE",
                accentColor: accentColor,
                action: onContinue
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var resultText: String {
        if isCritical {
            return "CRITICAL! ⭐"
        } else if isFumble {
            return "FUMBLE! 💀"
        } else if isSuccess {
            return "SUCCESS"
        } else {
            return "FAILURE"
        }
    }
    
    private var resultColor: Color {
        if isCritical || isSuccess {
            return .green
        } else {
            return .red
        }
    }
}
