
import SwiftUI

struct DiceBonusSheet: View {
    @Environment(\.dismiss) private var dismiss
    let diceType: DiceType
    @Binding var proficiencyBonus: Int
    let onConfirm: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    headerView
                    
                    bonusView
                    
                    Spacer()
                    
                    confirmButton
                }
            }
            .navigationTitle("Configure Dice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FFD700"))
                }
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text(diceType.name)
                .font(.custom("PlayfairDisplay-Bold", size: 60))
                .foregroundColor(Color(hex: "#FFD700"))
            
            Text("Configure proficiency bonus")
                .font(.custom("PlayfairDisplay-Regular", size: 16))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var bonusView: some View {
        VStack(spacing: 20) {
            Text("Proficiency Bonus")
                .font(.custom("PlayfairDisplay-Bold", size: 18))
                .foregroundColor(.white)
            
            HStack(spacing: 30) {
                Button(action: {
                    if proficiencyBonus > -10 {
                        proficiencyBonus -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
                .disabled(proficiencyBonus <= -10)
                .opacity(proficiencyBonus <= -10 ? 0.3 : 1.0)
                
                Text("\(proficiencyBonus >= 0 ? "+" : "")\(proficiencyBonus)")
                    .font(.custom("PlayfairDisplay-Bold", size: 72))
                    .foregroundColor(Color(hex: "#FFD700"))
                    .frame(minWidth: 150)
                
                Button(action: {
                    if proficiencyBonus < 10 {
                        proficiencyBonus += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#FFD700"))
                }
                .disabled(proficiencyBonus >= 10)
                .opacity(proficiencyBonus >= 10 ? 0.3 : 1.0)
            }
            
            HStack(spacing: 12) {
                ForEach([0, 2, 5], id: \.self) { bonus in
                    Button(action: {
                        proficiencyBonus = bonus
                    }) {
                        Text("+\(bonus)")
                            .font(.custom("PlayfairDisplay-Bold", size: 16))
                            .foregroundColor(proficiencyBonus == bonus ? .black : Color(hex: "#FFD700"))
                            .frame(width: 60, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(proficiencyBonus == bonus ? Color(hex: "#FFD700")! : Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(hex: "#FFD700")!, lineWidth: 1.5)
                                    )
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var confirmButton: some View {
        Button(action: {
            onConfirm()
            dismiss()
        }) {
            Text("ROLL DICE")
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#FFD700")!)
                        .shadow(color: Color(hex: "#FFD700")!.opacity(0.5), radius: 10)
                )
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
    }
}
