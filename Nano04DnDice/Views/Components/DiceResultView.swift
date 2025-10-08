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
        VStack(spacing: 10) {
            // Roll Mode Info
            if rollMode != .normal, let second = secondResult {
                VStack(spacing: 4) {
                    Text(rollMode == .blessed ? "🙏 ABENÇOADO" : "👿 AMALDIÇOADO")
                        .font(.custom("PlayfairDisplay-Bold", size: 12))
                        .foregroundColor(rollMode == .blessed ? .green : .red)
                    
                    HStack(spacing: 6) {
                        Text("[\(second)]")
                            .font(.custom("PlayfairDisplay-Regular", size: 16))
                            .foregroundColor(.white.opacity(0.5))
                            .strikethrough()
                        
                        Text("[\(result)]")
                            .font(.custom("PlayfairDisplay-Bold", size: 18))
                            .foregroundColor(accentColor)
                    }
                }
            }
            
            // Result Text
            Text(resultText)
                .font(.custom("PlayfairDisplay-Black", size: 20))
                .foregroundColor(resultColor)
                .shadow(color: resultColor.opacity(0.5), radius: 8)
            
            // Continue Button
            ActionButton(
                title: "CONTINUAR",
                accentColor: accentColor,
                action: onContinue
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var resultText: String {
        if isCritical {
            return "CRÍTICO! ⭐"
        } else if isFumble {
            return "FALHA! 💀"
        } else if isSuccess {
            return "SUCESSO"
        } else {
            return "FALHA"
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
