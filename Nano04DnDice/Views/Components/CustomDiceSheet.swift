
import SwiftUI

struct CustomDiceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var diceSides: String
    @Binding var proficiencyBonus: Int
    let onConfirm: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    headerView
                    
                    inputView
                    
                    bonusView
                    
                    quickSelectView
                    
                    Spacer()
                    
                    confirmButton
                }
            }
            .navigationTitle("Custom Dice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FFD700"))
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    
    private var headerView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {  // 16pt
            Image(systemName: "dice.fill")
                .font(.system(size: 80))
            
            Text("Custom Dice")
                .font(.custom("PlayfairDisplay-Bold", size: 28))
                .foregroundColor(.white)
            
            Text("Enter number of sides (2-100)")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
    
    private var inputView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {  // 12pt
            TextField("20", text: $diceSides)
                .keyboardType(.numberPad)
                .font(.custom("PlayfairDisplay-Bold", size: 60))
                .foregroundColor(Color(hex: "#FFD700"))
                .multilineTextAlignment(.center)
                .focused($isTextFieldFocused)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                        .fill(DesignSystem.Colors.backgroundOverlay)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                                .stroke(Color(hex: "#FFD700")!, lineWidth: 2)
                        )
                )
            
            if let sides = Int(diceSides) {
                if sides < 2 || sides > 100 {
                    Text("⚠️ Enter a number between 2 and 100")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var bonusView: some View {
        VStack(spacing: 8) {
            Text("Proficiency Bonus")
                .font(.custom("PlayfairDisplay-Regular", size: 12))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            HStack(spacing: 16) {
                Button(action: {
                    if proficiencyBonus > -10 {
                        proficiencyBonus -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
                .disabled(proficiencyBonus <= -10)
                .opacity(proficiencyBonus <= -10 ? 0.3 : 1.0)
                
                Text("\(proficiencyBonus >= 0 ? "+" : "")\(proficiencyBonus)")
                    .font(.custom("PlayfairDisplay-Bold", size: 32))
                    .foregroundColor(Color(hex: "#FFD700"))
                    .frame(minWidth: 80)
                
                Button(action: {
                    if proficiencyBonus < 10 {
                        proficiencyBonus += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
                .disabled(proficiencyBonus >= 10)
                .opacity(proficiencyBonus >= 10 ? 0.3 : 1.0)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var quickSelectView: some View {
        VStack(spacing: 12) {
            Text("Quick Shortcuts")
                .font(.custom("PlayfairDisplay-Bold", size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 12) {
                ForEach([30, 50, 100], id: \.self) { sides in
                    Button(action: {
                        diceSides = "\(sides)"
                    }) {
                        Text("D\(sides)")
                            .font(.custom("PlayfairDisplay-Bold", size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                                    .fill(Color(hex: "#FFD700")!)
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var confirmButton: some View {
        Button(action: onConfirm) {
            Text("CONFIRM")
                .font(.custom("PlayfairDisplay-Bold", size: 18))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                        .fill(Color(hex: "#FFD700")!)
                        .shadow(color: Color(hex: "#FFD700")!.opacity(0.5), radius: 10)  // Mantém relativo ao dourado
                )
        }
        .disabled(!isValidInput)
        .opacity(isValidInput ? 1.0 : 0.5)
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
    }
    
    
    private var isValidInput: Bool {
        if let sides = Int(diceSides) {
            return sides >= 2 && sides <= 100
        }
        return false
    }
}
