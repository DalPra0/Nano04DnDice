//
//  DiceRollerView.swift
//  Nano04DnDice
//
//  View principal - LANDSCAPE APENAS - TUDO NA TELA
//

import SwiftUI

struct DiceRollerView: View {
    @StateObject private var viewModel = DiceRollerViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    
    private var currentTheme: DiceCustomization {
        themeManager.currentTheme
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    currentTheme.backgroundColor.color
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Top Buttons
                        TopButtonsView(
                            accentColor: currentTheme.accentColor.color,
                            onShowThemes: { viewModel.showThemesList = true },
                            onShowCustomizer: { viewModel.showCustomizer = true }
                        )
                        
                        // Main Content
                        mainContent(geometry: geometry)
                            .padding(.top, 8)
                    }
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
                    onConfirm: viewModel.confirmCustomDice
                )
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.startAmbientAnimation()
        }
    }
    
    // MARK: - Main Content
    
    private func mainContent(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        return HStack(spacing: 16) {
            // LEFT SIDE - 38%
            leftSide
                .frame(width: screenWidth * 0.38)
            
            // RIGHT SIDE - 52%
            rightSide(screenWidth: screenWidth, screenHeight: screenHeight)
                .frame(width: screenWidth * 0.52)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    // MARK: - Left Side
    
    private var leftSide: some View {
        VStack(spacing: 12) {
            // Header
            DiceHeaderView(
                diceName: viewModel.selectedDiceType.name,
                accentColor: currentTheme.accentColor.color
            )
            
            // Dice Selector
            DiceSelectorView(
                selectedDiceType: viewModel.selectedDiceType,
                accentColor: currentTheme.accentColor.color,
                onSelectDice: viewModel.selectDiceType,
                onShowCustomDice: { viewModel.showCustomDice = true }
            )
            
            // Roll Mode
            RollModeSelectorView(
                selectedMode: viewModel.rollMode,
                accentColor: currentTheme.accentColor.color,
                onSelectMode: viewModel.selectRollMode
            )
        }
    }
    
    // MARK: - Right Side
    
    private func rightSide(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        // DADO - 50% da altura disponível
        let availableHeight = screenHeight - 80
        let diceSize = min(screenWidth * 0.45, availableHeight * 0.6)
        
        return VStack(spacing: 12) {
            // Dice Display
            DiceDisplayView(
                diceSize: diceSize,
                currentNumber: viewModel.result ?? viewModel.currentRoll,
                isRolling: viewModel.rolling,
                glowIntensity: viewModel.glowIntensity * currentTheme.glowIntensity,
                diceBorderColor: currentTheme.diceBorderColor.color,
                accentColor: currentTheme.accentColor.color,
                onRollComplete: viewModel.handleRollComplete
            )
            
            // Result or Roll Button
            if let result = viewModel.result {
                DiceResultView(
                    result: result,
                    secondResult: viewModel.secondResult,
                    rollMode: viewModel.rollMode,
                    diceSides: viewModel.selectedDiceType.sides,
                    accentColor: currentTheme.accentColor.color,
                    onContinue: viewModel.continueAfterResult
                )
            } else {
                RollButtonView(
                    diceType: viewModel.selectedDiceType,
                    rollMode: viewModel.rollMode,
                    isRolling: viewModel.rolling,
                    accentColor: currentTheme.accentColor.color,
                    onRoll: viewModel.rollDice
                )
            }
        }
    }
}

#Preview {
    DiceRollerView()
}
