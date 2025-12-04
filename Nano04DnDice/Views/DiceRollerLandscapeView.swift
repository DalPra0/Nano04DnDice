
import SwiftUI

struct DiceRollerLandscapeView: View {
    @ObservedObject var viewModel: DiceRollerViewModel
    @ObservedObject var themeManager: ThemeManager
    
    private var currentTheme: DiceCustomization {
        themeManager.currentTheme
    }
    
    var body: some View {
        ZStack {
            currentTheme.backgroundColor.color
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ZStack {
                        currentTheme.backgroundColor.color
                        
                        VStack(spacing: 20) {
                            Spacer()
                            
                            VStack(spacing: 16) {
                                if let result = viewModel.result {
                                    VStack(spacing: 4) {
                                        Text("RESULT")
                                            .font(.custom("PlayfairDisplay-Bold", size: 12))
                                            .foregroundColor(.white.opacity(0.4))
                                            .tracking(3)
                                        
                                        Text("\(result)")
                                            .font(.custom("PlayfairDisplay-Black", size: 56))
                                            .foregroundColor(currentTheme.accentColor.color)
                                    }
                                } else {
                                    Text("TAP TO ROLL")
                                        .font(.custom("PlayfairDisplay-Regular", size: 11))
                                        .foregroundColor(.white.opacity(0.25))
                                        .tracking(2)
                                }
                                
                                ThreeJSWebView(
                                    currentNumber: viewModel.result ?? 1,
                                    isRolling: viewModel.rolling,
                                    diceSides: viewModel.selectedDiceType.sides,
                                    onRollComplete: { _ in }
                                )
                                .aspectRatio(1, contentMode: .fit)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.02))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(currentTheme.diceBorderColor.color.opacity(0.25), lineWidth: 1.5)
                                        )
                                )
                                .padding(12)
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: geometry.size.width * 0.5)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !viewModel.rolling {
                            viewModel.rollDice()
                        }
                    }
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 32) {
                            Text(viewModel.selectedDiceType.shortName.uppercased())
                                .font(.custom("PlayfairDisplay-Black", size: 36))
                                .foregroundColor(currentTheme.accentColor.color)
                                .tracking(1)
                            
                            VStack(spacing: 14) {
                                HStack(spacing: 14) {
                                    diceButton(.d4)
                                    diceButton(.d6)
                                }
                                HStack(spacing: 14) {
                                    diceButton(.d8)
                                    diceButton(.d10)
                                }
                                HStack(spacing: 14) {
                                    diceButton(.d12)
                                    diceButton(.d20)
                                }
                            }
                            .padding(.horizontal, 28)
                            
                            Button(action: {
                                if !viewModel.rolling {
                                    viewModel.rollDice()
                                }
                            }) {
                                Text("ROLL")
                                    .font(.custom("PlayfairDisplay-Bold", size: 22))
                                    .foregroundColor(.black)
                                    .tracking(2)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(currentTheme.accentColor.color)
                                            .shadow(color: currentTheme.accentColor.color.opacity(0.3), radius: 12, x: 0, y: 4)
                                    )
                            }
                            .disabled(viewModel.rolling)
                            .opacity(viewModel.rolling ? 0.5 : 1.0)
                            .padding(.horizontal, 28)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .frame(width: geometry.size.width * 0.5)
                    .background(currentTheme.backgroundColor.color)
                }
            }
        }
        .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func diceButton(_ dice: DiceType) -> some View {
        let isSelected = viewModel.selectedDiceType == dice
        
        return Button(action: {
            viewModel.selectedDiceType = dice
        }) {
            Text(dice.shortName)
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(isSelected ? .black : currentTheme.accentColor.color)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? currentTheme.accentColor.color : Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? Color.clear : currentTheme.diceBorderColor.color.opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: isSelected ? currentTheme.accentColor.color.opacity(0.2) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 2
                        )
                )
        }
    }
}
