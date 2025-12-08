import SwiftUI

struct MultipleDiceResultView: View {
    let result: MultipleDiceRoll
    let accentColor: Color
    let backgroundColor: Color
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(result.results.enumerated()), id: \.offset) { index, value in
                        Text("\(value)")
                            .font(.custom("PlayfairDisplay-Black", size: 56))
                            .foregroundColor(diceColor(for: value))
                            .frame(width: 90, height: 110)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                                            .stroke(diceColor(for: value).opacity(0.6), lineWidth: 3)  // Mantém relativo à cor do dado
                                    )
                            )
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 120)
            
            VStack(spacing: 8) {
                Text("TOTAL")
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
                    .foregroundColor(backgroundColor.contrastTextSecondary)
                    .tracking(3)
                
                Text("\(result.total)")
                    .font(.custom("PlayfairDisplay-Black", size: 72))
                    .foregroundColor(accentColor)
            }
            .padding(.vertical, 8)
            .padding(.vertical, 8)
            
            if result.quantity > 1 {
                HStack(spacing: 32) {
                    statItem(label: "AVG", value: String(format: "%.1f", result.average))
                    statItem(label: "MAX", value: "\(result.results.max() ?? 0)")
                    statItem(label: "MIN", value: "\(result.results.min() ?? 0)")
                }
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(backgroundColor.contrastTextSecondary)
                .padding(.top, 4)
            }
            
            Button(action: onContinue) {
                Text("CONTINUE")
                    .font(.custom("PlayfairDisplay-Bold", size: 20))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                            .fill(accentColor)
                    )
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 20)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.custom("PlayfairDisplay-Bold", size: 10))
            Text(value)
                .font(.custom("PlayfairDisplay-Regular", size: 14))
        }
    }
    
    private func diceColor(for value: Int) -> Color {
        if value == result.diceType.sides {
            return .green  // Critical
        } else if value == 1 {
            return .red  // Fumble
        } else {
            return accentColor
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        MultipleDiceResultView(
            result: MultipleDiceRoll(
                diceType: .d6,
                quantity: 3,
                results: [4, 6, 2]
            ),
            accentColor: Color(hex: "#FFD700")!,
            backgroundColor: .black,
            onContinue: {}
        )
    }
}
