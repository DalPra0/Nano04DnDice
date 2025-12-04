
import SwiftUI

struct DiceRollerView: View {
    @StateObject private var viewModel = DiceRollerViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var orientation = UIDevice.current.orientation
    
    private var currentTheme: DiceCustomization {
        themeManager.currentTheme
    }
    
    private var isLandscape: Bool {
        orientation.isLandscape
    }
    
    var body: some View {
        Group {
            if isLandscape {
                DiceRollerLandscapeView(
                    viewModel: viewModel,
                    themeManager: themeManager
                )
            } else {
                portraitView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
    }
    
    private var portraitView: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    currentTheme.backgroundColor.color
                        .ignoresSafeArea()
                    
                    mainContentPortrait(geometry: geometry)
                    
                    TopButtonsView(
                        accentColor: currentTheme.accentColor.color,
                        onShowThemes: { viewModel.showThemesList = true },
                        onShowCustomizer: { viewModel.showCustomizer = true },
                        onShowAR: { viewModel.showARDice = true }
                    )
                    .zIndex(1000)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showThemesList) {
                ThemesListView()
            }
            .sheet(isPresented: $viewModel.showCustomizer) {
                ThemeCustomizerView()
            }
            .sheet(isPresented: $viewModel.showCustomDice) {
                CustomDiceSheet(
                    diceSides: $viewModel.customDiceSides,
                    proficiencyBonus: $viewModel.proficiencyBonus,
                    onConfirm: viewModel.confirmCustomDice
                )
            }
            .sheet(isPresented: $viewModel.showMultipleDice, onDismiss: {
                viewModel.multipleDiceResult = nil
            }) {
                MultipleDiceSheet(
                    quantity: $viewModel.multipleDiceQuantity,
                    diceType: $viewModel.multipleDiceType,
                    result: $viewModel.multipleDiceResult,
                    onConfirm: viewModel.rollMultipleDice,
                    backgroundColor: currentTheme.backgroundColor.color,
                    accentColor: currentTheme.accentColor.color,
                    borderColor: currentTheme.diceBorderColor.color
                )
            }
            .fullScreenCover(isPresented: $viewModel.showARDice) {
                ARDiceView(themeManager: themeManager)
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.startAmbientAnimation()
        }
        .onShake {
            if !viewModel.rolling && viewModel.result == nil {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                viewModel.rollDice()
            }
        }
        .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    
    
    private func mainContentPortrait(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        return VStack(spacing: 0) {
            Spacer()
                .frame(height: 50)
            
            topSection(screenWidth: screenWidth, screenHeight: screenHeight)
                .frame(height: screenHeight * 0.50)
            
            bottomSection(screenWidth: screenWidth, screenHeight: screenHeight)
                .frame(height: screenHeight * 0.50)
        }
    }
    
    
    private func topSection(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        let diceSize = min(screenWidth * 0.92, screenHeight * 0.42)
        
        return VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            DiceHeaderView(
                diceName: viewModel.selectedDiceType.name,
                accentColor: currentTheme.accentColor.color,
                backgroundColor: currentTheme.backgroundColor.color
            )
            .zIndex(10)
            
            DiceDisplayView(
                diceSize: diceSize,
                currentNumber: viewModel.result ?? viewModel.currentRoll,
                isRolling: viewModel.rolling,
                glowIntensity: viewModel.glowIntensity * currentTheme.glowIntensity,
                diceBorderColor: currentTheme.diceBorderColor.color,
                accentColor: currentTheme.accentColor.color,
                diceSides: viewModel.selectedDiceType.sides,
                onRollComplete: { _ in 
                    viewModel.handleRollComplete(viewModel.currentRoll)
                }
            )
            .padding(.vertical, 16)
            .zIndex(1)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 24)
    }
    
    
    private func bottomSection(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        VStack(spacing: 12) {
            DiceSelectorView(
                selectedDiceType: viewModel.selectedDiceType,
                accentColor: currentTheme.accentColor.color,
                onSelectDice: viewModel.selectDiceType,
                onShowCustomDice: { viewModel.showCustomDice = true },
                onShowMultipleDice: { viewModel.showMultipleDice = true }
            )
            .padding(.top, 8)
            
            RollModeSelectorView(
                selectedMode: viewModel.rollMode,
                accentColor: currentTheme.accentColor.color,
                backgroundColor: currentTheme.backgroundColor.color,
                onSelectMode: viewModel.selectRollMode
            )
            
            if let multipleDiceResult = viewModel.multipleDiceResult {
                MultipleDiceResultView(
                    result: multipleDiceResult,
                    accentColor: currentTheme.accentColor.color,
                    backgroundColor: currentTheme.backgroundColor.color,
                    onContinue: viewModel.continueAfterResult
                )
            } else if let result = viewModel.result {
                DiceResultView(
                    result: result,
                    secondResult: viewModel.secondResult,
                    rollMode: viewModel.rollMode,
                    diceSides: viewModel.selectedDiceType.sides,
                    accentColor: currentTheme.accentColor.color,
                    backgroundColor: currentTheme.backgroundColor.color,
                    shadowEnabled: currentTheme.shadowEnabled,
                    glowIntensity: currentTheme.glowIntensity,
                    proficiencyBonus: viewModel.proficiencyBonus,
                    onContinue: viewModel.continueAfterResult
                )
            } else {
                RollButtonView(
                    diceType: viewModel.selectedDiceType,
                    rollMode: viewModel.rollMode,
                    isRolling: viewModel.rolling,
                    accentColor: currentTheme.accentColor.color,
                    shadowEnabled: currentTheme.shadowEnabled,
                    glowIntensity: currentTheme.glowIntensity,
                    onRoll: viewModel.rollDice
                )
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }
}

#Preview {
    DiceRollerView()
}
