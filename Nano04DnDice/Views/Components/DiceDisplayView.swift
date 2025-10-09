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
    let onRollComplete: (Int) -> Void
    
    var body: some View {
        ZStack {
            // Border
            RoundedRectangle(cornerRadius: 16)
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
                    lineWidth: 2
                )
                .frame(width: diceSize, height: diceSize)
                .shadow(color: diceBorderColor.opacity(0.4), radius: 12)
            
            // Background
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.8)
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 80
                    )
                )
                .frame(width: diceSize - 4, height: diceSize - 4)
            
            // Dice 3D - padding mínimo para melhor aproveitamento
            ThreeJSWebView(
                currentNumber: currentNumber,
                isRolling: isRolling,
                onRollComplete: onRollComplete
            )
            .frame(width: diceSize - 6, height: diceSize - 6)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: accentColor.opacity(glowIntensity), radius: 14)
        }
    }
}
