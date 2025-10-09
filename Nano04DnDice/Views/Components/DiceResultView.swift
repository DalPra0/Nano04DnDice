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
    let shadowEnabled: Bool
    let glowIntensity: Double
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
                            .foregroundColor(.white.opacity(0.5))
                            .strikethrough()
                        
                        Text("[\(result)]")
                            .font(.custom("PlayfairDisplay-Bold", size: 20))
                            .foregroundColor(accentColor)
                    }
                }
            }
            
            // Result Text
            Text(resultText)
                .font(.custom("PlayfairDisplay-Black", size: 24))
                .foregroundColor(resultColor)
            
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
    
    private var resultText: String {
        if isCritical {
            return "CRITICAL!"
        } else if isFumble {
            return "FUMBLE!"
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
