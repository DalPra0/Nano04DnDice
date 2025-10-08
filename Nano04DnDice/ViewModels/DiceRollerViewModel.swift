//
//  DiceRollerViewModel.swift
//  Nano04DnDice
//
//  ViewModel principal - gerencia estado e lógica do dado
//

import SwiftUI
import Combine

class DiceRollerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var rolling = false
    @Published var result: Int?
    @Published var secondResult: Int?
    @Published var currentRoll = 1
    @Published var glowIntensity: Double = 0.3
    @Published var selectedDiceType: DiceType = .d20
    @Published var rollMode: RollMode = .normal
    
    @Published var showThemesList = false
    @Published var showCustomizer = false
    @Published var showCustomDice = false
    @Published var customDiceSides: String = "20"
    
    // MARK: - Dependencies
    private let audioManager = AudioManager.shared
    
    // MARK: - Computed Properties
    var hasResult: Bool {
        result != nil
    }
    
    var isCritical: Bool {
        guard let result = result else { return false }
        return result == selectedDiceType.sides
    }
    
    var isFumble: Bool {
        guard let result = result else { return false }
        return result == 1
    }
    
    var isSuccess: Bool {
        guard let result = result else { return false }
        return result >= (selectedDiceType.sides / 2)
    }
    
    // MARK: - Public Methods
    
    func startAmbientAnimation() {
        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowIntensity = 0.6
        }
    }
    
    func selectDiceType(_ type: DiceType) {
        selectedDiceType = type
        result = nil
        secondResult = nil
    }
    
    func selectRollMode(_ mode: RollMode) {
        rollMode = mode
        result = nil
        secondResult = nil
    }
    
    func confirmCustomDice() {
        if let sides = Int(customDiceSides), sides >= 2, sides <= 100 {
            selectedDiceType = .custom(sides: sides)
            showCustomDice = false
        }
    }
    
    func rollDice() {
        rolling = true
        result = nil
        secondResult = nil
        
        currentRoll = Int.random(in: 1...selectedDiceType.sides)
        
        audioManager.playDiceRoll()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            glowIntensity = 1.0
        }
        
        // Handle blessed/cursed rolls
        if rollMode != .normal {
            let secondRoll = Int.random(in: 1...selectedDiceType.sides)
            secondResult = secondRoll
            
            if rollMode == .blessed {
                currentRoll = max(currentRoll, secondRoll)
            } else {
                currentRoll = min(currentRoll, secondRoll)
            }
        }
        
        // Finish roll after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            if self.rolling {
                self.result = self.currentRoll
                self.rolling = false
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.glowIntensity = 0.3
                }
            }
        }
    }
    
    func handleRollComplete(_ finalResult: Int) {
        result = finalResult
        rolling = false
        
        if finalResult == selectedDiceType.sides {
            audioManager.playCritical()
        } else if finalResult == 1 {
            audioManager.playFumble()
        } else {
            audioManager.playDiceResult(success: finalResult >= (selectedDiceType.sides / 2))
        }
    }
    
    func continueAfterResult() {
        result = nil
        secondResult = nil
        currentRoll = Int.random(in: 1...selectedDiceType.sides)
    }
}
