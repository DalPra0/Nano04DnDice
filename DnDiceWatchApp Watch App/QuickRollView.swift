
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
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    Text(diceType.name)
                        .font(.title2) // 22pt (was title3 20pt)
                        .fontWeight(.bold)
                    
                    if let result = result {
                        QuickResultView(
                            result: result,
                            diceType: diceType,
                            isAnimating: isAnimating,
                            isAOD: isLuminanceReduced,
                            geometry: geometry
                        )
                    } else {
                        Image(systemName: "dice.fill")
                            .font(.system(size: min(geometry.size.width * 0.3, 60)))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 20)
                    }
                    
                    Button(action: roll) {
                        Text("ROLL")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44) // Minimum touch target
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .onAppear {
            // Auto-roll on appear (instant, no delay)
            roll()
        }
    }
    
    private func roll() {
        isAnimating = true
        WKInterfaceDevice.current().play(.success)
        
        // Instant result (watchOS best practice)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            result = Int.random(in: 1...diceType.sides)
            isAnimating = false
        }
    }
}

struct QuickResultView: View {
    let result: Int
    let diceType: WatchDiceType
    let isAnimating: Bool
    let isAOD: Bool
    let geometry: GeometryProxy
    
    var isCritical: Bool {
        result == diceType.sides
    }
    
    var isFumble: Bool {
        result == 1
    }
    
    var resultColor: Color {
        if isAOD { return .white }
        if isCritical { return .green }
        if isFumble { return .red }
        return .accentColor
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("\(result)")
                .font(.system(size: min(geometry.size.width * 0.35, 70), weight: .bold, design: .rounded))
                .foregroundColor(resultColor)
                .scaleEffect(isAnimating ? 1.15 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isAnimating)
            
            if !isAOD {
                if isCritical {
                    Text("CRITICAL!")
                        .font(.caption) // 12pt (was caption2 11pt)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else if isFumble {
                    Text("FUMBLE!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    QuickRollView(diceType: .d20)
}
