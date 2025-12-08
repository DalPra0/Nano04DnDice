import SwiftUI

struct MultipleDiceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var quantity: Int
    @Binding var diceType: DiceType
    @Binding var result: MultipleDiceRoll?
    let onConfirm: () -> Void
    let backgroundColor: Color
    let accentColor: Color
    let borderColor: Color
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.lg) {  // 24pt
                    Spacer()
                    
                    if let roll = result {
                        resultView(roll)
                    } else {
                        setupView
                    }
                    
                    Spacer()
                    
                    if result != nil {
                        continueButton
                    } else {
                        rollButton
                    }
                }
                .padding(DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
            }
            .navigationTitle("Multiple Dice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    
    private var setupView: some View {
        VStack(spacing: 32) {
            headerView
            quantitySelector
            diceTypeSelector
            presetsView
        }
    }
    
    private func resultView(_ roll: MultipleDiceRoll) -> some View {
        VStack(spacing: 0) {
            Text(roll.displayName)
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(accentColor.opacity(0.6))
                .padding(.bottom, 32)
            
            VStack(spacing: 8) {
                Text("TOTAL")
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
                    .tracking(6)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text("\(roll.total)")
                    .font(.custom("PlayfairDisplay-Black", size: 120))
                    .foregroundColor(accentColor)
                    .minimumScaleFactor(0.5)
            }
            .padding(.vertical, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(roll.results.enumerated()), id: \.offset) { index, value in
                        diceResultCard(value: value, maxValue: roll.diceType.sides, index: index + 1)
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 24)
            
            if roll.quantity > 1 {
                HStack(spacing: 0) {
                    Spacer()
                    statItem(label: "AVG", value: String(format: "%.1f", roll.average))
                    Spacer()
                    Divider()
                        .background(DesignSystem.Colors.borderSubtle)
                        .frame(height: 30)
                    Spacer()
                    statItem(label: "MAX", value: "\(roll.results.max() ?? 0)")
                    Spacer()
                    Divider()
                        .background(DesignSystem.Colors.borderSubtle)
                        .frame(height: 30)
                    Spacer()
                    statItem(label: "MIN", value: "\(roll.results.min() ?? 0)")
                    Spacer()
                }
                .padding(.top, 16)
            }
        }
    }
    
    private func diceResultCard(value: Int, maxValue: Int, index: Int) -> some View {
        let isCritical = value == maxValue
        let isFumble = value == 1
        let cardColor: Color = isCritical ? .green : (isFumble ? .red : accentColor)
        
        return VStack(spacing: 8) {
            Text("\(value)")
                .font(.custom("PlayfairDisplay-Black", size: 48))
                .foregroundColor(cardColor)
            
            Text("dice \(index)")
                .font(.custom("PlayfairDisplay-Regular", size: 11))
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .textCase(.uppercase)
                .tracking(1)
        }
        .frame(width: 85, height: 95)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                        .stroke(borderColor.opacity(0.4), lineWidth: 1.5)
                )
        )
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("PlayfairDisplay-Bold", size: 28))
                .foregroundColor(accentColor)
            Text(label)
                .font(.custom("PlayfairDisplay-Bold", size: 13))
                .foregroundColor(.white.opacity(0.7))
                .tracking(2)
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            dismiss()
        }) {
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
        .padding(.horizontal, 20)
    }
    
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("\(quantity)D\(diceType.sides)")
                .font(.custom("PlayfairDisplay-Black", size: 60))
                .foregroundColor(accentColor)
                .shadow(color: accentColor.opacity(0.5), radius: 15, x: 0, y: 0)
            
            Text("Roll multiple dice at once")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
    
    private var quantitySelector: some View {
        VStack(spacing: 12) {
            Text("Quantity")
                .font(.custom("PlayfairDisplay-Bold", size: 16))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            HStack(spacing: 20) {
                Button(action: {
                    if quantity > 1 {
                        quantity -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
                .disabled(quantity <= 1)
                .opacity(quantity <= 1 ? 0.3 : 1.0)
                
                Text("\(quantity)")
                    .font(.custom("PlayfairDisplay-Black", size: 48))
                    .foregroundColor(Color(hex: "#FFD700"))
                    .frame(minWidth: 80)
                
                Button(action: {
                    if quantity < 20 {
                        quantity += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
                .disabled(quantity >= 20)
                .opacity(quantity >= 20 ? 0.3 : 1.0)
            }
        }
    }
    
    private var diceTypeSelector: some View {
        VStack(spacing: 12) {
            Text("Dice Type")
                .font(.custom("PlayfairDisplay-Bold", size: 16))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([DiceType.d4, .d6, .d8, .d10, .d12, .d20], id: \.self) { dice in
                        diceButton(dice)
                    }
                }
            }
        }
    }
    
    private func diceButton(_ dice: DiceType) -> some View {
        Button(action: { diceType = dice }) {
            Text(dice.shortName)
                .font(.custom("PlayfairDisplay-Bold", size: 18))
                .foregroundColor(diceType == dice ? .black : Color(hex: "#FFD700"))
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                        .fill(diceType == dice ? Color(hex: "#FFD700")! : DesignSystem.Colors.backgroundOverlay)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                                .stroke(Color(hex: "#FFD700")!, lineWidth: 2)
                        )
                )
        }
    }
    
    private var presetsView: some View {
        VStack(spacing: 12) {
            Text("Quick Presets")
                .font(.custom("PlayfairDisplay-Bold", size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 12) {
                ForEach(MultipleDicePreset.allCases) { preset in
                    Button(action: {
                        quantity = preset.quantity
                        diceType = preset.diceType
                    }) {
                        Text(preset.rawValue)
                            .font(.custom("PlayfairDisplay-Bold", size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                                    .fill(Color.white.opacity(0.9))
                            )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var rollButton: some View {
        Button(action: {
            onConfirm()
        }) {
            Text("ROLL \(quantity)D\(diceType.sides)")
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                        .fill(accentColor)
                        .shadow(color: accentColor.opacity(0.4), radius: 15, x: 0, y: 5)
                )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    MultipleDiceSheet(
        quantity: .constant(3),
        diceType: .constant(.d6),
        result: .constant(nil),
        onConfirm: {},
        backgroundColor: .black,
        accentColor: Color(hex: "#FFD700")!,
        borderColor: Color(hex: "#FFD700")!
    )
}
