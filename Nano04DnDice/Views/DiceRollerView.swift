
import SwiftUI

struct DiceRollerView: View {
    @StateObject private var viewModel = DiceRollerViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var orientation = UIDevice.current.orientation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var currentTheme: DiceCustomization {
        themeManager.currentTheme
    }
    
    private var isLandscape: Bool {
        orientation.isLandscape
    }
    
    /// Check if device is iPad (regular width in portrait)
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
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
                        onShowThemes: { viewModel.navigation.showThemesList = true },
                        onShowCustomizer: { viewModel.navigation.showCustomizer = true },
                        onShowAR: { viewModel.navigation.showARDice = true },
                        onShowHistory: { viewModel.navigation.showHistory = true },
                        onShowDetailedStats: { viewModel.navigation.showDetailedStats = true },
                        onShowAudioSettings: { viewModel.navigation.showAudioSettings = true },
                        onShowCampaignManager: { viewModel.navigation.showCampaignManager = true },
                        onShowCharacterSheet: { viewModel.navigation.showCharacterSheet = true }
                    )
                    .zIndex(1000)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.navigation.showHistory) {
                DiceRollHistoryView()
            }
            .sheet(isPresented: $viewModel.navigation.showDetailedStats) {
                DetailedStatisticsView(themeManager: themeManager)
            }
            .sheet(isPresented: $viewModel.navigation.showAudioSettings) {
                AudioSettingsView(themeManager: themeManager)
            }
            .sheet(isPresented: $viewModel.navigation.showCampaignManager) {
                CampaignManagerView()
            }
            .sheet(isPresented: $viewModel.navigation.showCharacterSheet) {
                CharacterSheetView()
            }
            .sheet(isPresented: $viewModel.navigation.showThemesList) {
                ThemesListView()
            }
            .sheet(isPresented: $viewModel.navigation.showCustomizer) {
                ThemeCustomizerView()
            }
            .sheet(isPresented: $viewModel.navigation.showCustomDice) {
                CustomDiceSheet(
                    diceSides: $viewModel.customDiceSides,
                    proficiencyBonus: $viewModel.proficiencyBonus,
                    onConfirm: viewModel.confirmCustomDice
                )
            }
            .sheet(isPresented: $viewModel.navigation.showMultipleDice, onDismiss: {
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
            .fullScreenCover(isPresented: $viewModel.navigation.showARDice) {
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
        
        // iPad optimization: increase spacing and size for larger screens
        let verticalSpacing: CGFloat = isIPad ? DesignSystem.Spacing.xl : 0
        let topRatio: CGFloat = isIPad ? 0.55 : 0.50
        let bottomRatio: CGFloat = isIPad ? 0.45 : 0.50
        
        return VStack(spacing: verticalSpacing) {
            Spacer()
                .frame(height: isIPad ? 80 : 50)
            
            topSection(screenWidth: screenWidth, screenHeight: screenHeight)
                .frame(height: screenHeight * topRatio)
            
            bottomSection(screenWidth: screenWidth, screenHeight: screenHeight)
                .frame(height: screenHeight * bottomRatio)
        }
    }
    
    
    private func topSection(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        // iPad optimization: larger dice size for bigger screens
        let diceMultiplier: CGFloat = isIPad ? 0.65 : 0.92
        let diceSize = min(screenWidth * diceMultiplier, screenHeight * 0.42)
        
        return VStack(spacing: DesignSystem.Spacing.lg) {  // 24pt
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
            .padding(.vertical, DesignSystem.Spacing.md)  // 16pt
            .zIndex(1)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)  // 8pt
        .padding(.bottom, DesignSystem.Spacing.lg)  // 24pt
    }
    
    
    private func bottomSection(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {  // 12pt
            DiceSelectorView(
                selectedDiceType: viewModel.selectedDiceType,
                accentColor: currentTheme.accentColor.color,
                onSelectDice: viewModel.selectDiceType,
                onShowCustomDice: { viewModel.navigation.showCustomDice = true },
                onShowMultipleDice: { viewModel.navigation.showMultipleDice = true }
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
