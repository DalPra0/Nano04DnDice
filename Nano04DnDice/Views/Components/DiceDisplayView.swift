//
//  DiceDisplayView.swift
//  Nano04DnDice
//
//  Componente - Exibição do dado 3D - DADO MAIOR DENTRO DO FRAME
//

import SwiftUI

struct DiceDisplayView: View {
    let diceSize: CGFloat
    let currentNumber: Int
    let isRolling: Bool
    let glowIntensity: Double
    let diceBorderColor: Color
    let accentColor: Color
    let diceSides: Int  // Número de lados do dado
    let onRollComplete: (Int) -> Void
    
    var body: some View {
        ZStack {
            // Border
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            diceBorderColor.opacity(0.8),
                            diceBorderColor.opacity(0.3),
                            diceBorderColor.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: diceSize, height: diceSize)
                .shadow(color: diceBorderColor.opacity(0.5), radius: 16)
            
            // Background
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.8)
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 100
                    )
                )
                .frame(width: diceSize - 6, height: diceSize - 6)
            
            // Dice 3D - MAIORZÃO - padding mínimo
            ThreeJSWebView(
                currentNumber: currentNumber,
                isRolling: isRolling,
                diceSides: diceSides,
                onRollComplete: onRollComplete
            )
            .frame(width: diceSize - 8, height: diceSize - 8)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: accentColor.opacity(glowIntensity), radius: 18)
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
