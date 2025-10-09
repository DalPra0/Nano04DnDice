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
                        
                        // Main Content - PORTRAIT LAYOUT
                        mainContentPortrait(geometry: geometry)
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
    
    // MARK: - Main Content - PORTRAIT MODE
    
    private func mainContentPortrait(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        return VStack(spacing: 0) {
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
        let diceSize = min(screenWidth * 0.80, screenHeight * 0.38)
        
        return VStack(spacing: 8) {
            Spacer(minLength: 0)
            
            // Header compacto
            DiceHeaderView(
                diceName: viewModel.selectedDiceType.name,
                accentColor: currentTheme.accentColor.color
            )
            
            // Dice Display - ENORME
            DiceDisplayView(
                diceSize: diceSize,
                currentNumber: viewModel.result ?? viewModel.currentRoll,
                isRolling: viewModel.rolling,
                glowIntensity: viewModel.glowIntensity * currentTheme.glowIntensity,
                diceBorderColor: currentTheme.diceBorderColor.color,
                accentColor: currentTheme.accentColor.color,
                onRollComplete: viewModel.handleRollComplete
            )
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Bottom Section (Controls)
    
    private func bottomSection(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                // Dice Selector
                DiceSelectorView(
                    selectedDiceType: viewModel.selectedDiceType,
                    accentColor: currentTheme.accentColor.color,
                    onSelectDice: viewModel.selectDiceType,
                    onShowCustomDice: { viewModel.showCustomDice = true }
                )
                
                // Roll Mode Selector
                RollModeSelectorView(
                    selectedMode: viewModel.rollMode,
                    accentColor: currentTheme.accentColor.color,
                    onSelectMode: viewModel.selectRollMode
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
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    DiceRollerView()
}
