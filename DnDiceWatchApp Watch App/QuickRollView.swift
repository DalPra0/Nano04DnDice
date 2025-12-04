
//
//  QuickRollView.swift
//  DnDiceWatchApp Watch App
//
//  Created by Lucas Dal Pra Brascher on 04/12/25.
//

import SwiftUI
import WatchKit

struct QuickRollView: View {
    let diceType: WatchDiceType
    @State private var result: Int?
    @State private var isAnimating = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text(diceType.name)
                .font(.title3)
                .fontWeight(.bold)
            
            if let result = result {
                QuickResultView(
                    result: result,
                    diceType: diceType,
                    isAnimating: isAnimating
                )
            } else {
                Image(systemName: "dice.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
            }
            
            Button(action: roll) {
                Text("ROLL")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            // Auto-roll on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                roll()
            }
        }
    }
    
    private func roll() {
        isAnimating = true
        WKInterfaceDevice.current().play(.notification)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            result = Int.random(in: 1...diceType.sides)
            isAnimating = false
        }
    }
}

struct QuickResultView: View {
    let result: Int
    let diceType: WatchDiceType
    let isAnimating: Bool
    
    var isCritical: Bool {
        result == diceType.sides
    }
    
    var isFumble: Bool {
        result == 1
    }
    
    var resultColor: Color {
        if isCritical { return .green }
        if isFumble { return .red }
        return .accentColor
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(result)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(resultColor)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            
            if isCritical {
                Text("CRITICAL!")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            } else if isFumble {
                Text("FUMBLE!")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    QuickRollView(diceType: .d20)
}
