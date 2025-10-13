//
//  DiceRollerView.swift
//  Nano04DnDice
//
//  Main View - PORTRAIT MODE - Dice on top, controls below
//

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
                // LANDSCAPE MODE
                DiceRollerLandscapeView(
                    viewModel: viewModel,
                    themeManager: themeManager
                )
            } else {
                // PORTRAIT MODE
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
                    // Background
                    currentTheme.backgroundColor.color
                        .ignoresSafeArea()
                    
                    // Main Content - PORTRAIT LAYOUT (sem o TopButtons aqui)
                    mainContentPortrait(geometry: geometry)
                    
                    // Menu Hambúrguer - POR CIMA DE TUDO
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
                // Limpa o resultado quando fechar o sheet
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
    
    // MARK: - Portrait Layout
    
    // MARK: - Main Content - PORTRAIT MODE
    
    private func mainContentPortrait(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        return VStack(spacing: 0) {
            // Espaçamento no topo para não cortar o ROLLING D20
            Spacer()
                .frame(height: 50)
            
            // TOP HALF - DICE DISPLAY (50% da tela)
            topSection(screenWidth: screenWidth, screenHeight: screenHeight)
                .frame(height: screenHeight * 0.50)
            
            // BOTTOM HALF - CONTROLS (50% da tela)
            bottomSection(screenWidth: screenWidth, screenHeight: screenHeight)
                .frame(height: screenHeight * 0.50)
        }
    }
    
    // MARK: - Top Section (Dice)
    
    private func topSection(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        // DADO MAIORZÃO - quase tocando nas laterais
        let diceSize = min(screenWidth * 0.92, screenHeight * 0.42)
        
        return VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            // Header compacto - NA FRENTE (zIndex alto)
            DiceHeaderView(
                diceName: viewModel.selectedDiceType.name,
                accentColor: currentTheme.accentColor.color,
                backgroundColor: currentTheme.backgroundColor.color
            )
            .zIndex(10)
            
            // Dice Display - ENORME com mais espaçamento
            DiceDisplayView(
                diceSize: diceSize,
                currentNumber: viewModel.result ?? viewModel.currentRoll,
                isRolling: viewModel.rolling,
                glowIntensity: viewModel.glowIntensity * currentTheme.glowIntensity,
                diceBorderColor: currentTheme.diceBorderColor.color,
                accentColor: currentTheme.accentColor.color,
                diceSides: viewModel.selectedDiceType.sides,
                onRollComplete: { _ in 
                    // Ignora o resultado do WebView, usa o currentRoll já calculado
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
    
    // MARK: - Bottom Section (Controls)
    
    private func bottomSection(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        VStack(spacing: 12) {
            // Dice Selector - COM ESPAÇAMENTO DO DADO
            DiceSelectorView(
                selectedDiceType: viewModel.selectedDiceType,
                accentColor: currentTheme.accentColor.color,
                onSelectDice: viewModel.selectDiceType,
                onShowCustomDice: { viewModel.showCustomDice = true },
                onShowMultipleDice: { viewModel.showMultipleDice = true }
            )
            .padding(.top, 8)
            
            // Roll Mode Selector - COLLAPSIBLE
            RollModeSelectorView(
                selectedMode: viewModel.rollMode,
                accentColor: currentTheme.accentColor.color,
                backgroundColor: currentTheme.backgroundColor.color,
                onSelectMode: viewModel.selectRollMode
            )
            
            // Result or Roll Button
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
