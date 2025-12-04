
import SwiftUI
import Combine

class DiceRollerViewModel: ObservableObject {
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
    @Published var showARDice = false
    @Published var customDiceSides: String = "20"
    @Published var proficiencyBonus: Int = 0
    
    @Published var showMultipleDice = false
    @Published var multipleDiceQuantity: Int = 2
    @Published var multipleDiceType: DiceType = .d6
    @Published var multipleDiceResult: MultipleDiceRoll?
    
    private let audioManager = AudioManager.shared
    
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
        
        let firstRoll = Int.random(in: 1...selectedDiceType.sides)
        var finalRoll = firstRoll
        
        if rollMode != .normal {
            let secondRoll = Int.random(in: 1...selectedDiceType.sides)
            secondResult = secondRoll
            
            if rollMode == .blessed {
                finalRoll = max(firstRoll, secondRoll)
            } else {
                finalRoll = min(firstRoll, secondRoll)
            }
        }
        
        currentRoll = finalRoll
        
        audioManager.playDiceRoll()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            glowIntensity = 1.0
        }
        
    }
    
    func handleRollComplete(_ finalResult: Int) {
        result = finalResult + proficiencyBonus
        rolling = false
        
        withAnimation(.easeInOut(duration: 0.5)) {
            glowIntensity = 0.3
        }
        
        if finalResult == selectedDiceType.sides {
            audioManager.playCritical()
        } else if finalResult == 1 {
            audioManager.playFumble()
        }
    }
    
    func continueAfterResult() {
        result = nil
        secondResult = nil
        multipleDiceResult = nil
        currentRoll = Int.random(in: 1...selectedDiceType.sides)
    }
    
    func rollMultipleDice() {
        rolling = true
        multipleDiceResult = nil
        
        var results: [Int] = []
        for _ in 0..<multipleDiceQuantity {
            results.append(Int.random(in: 1...multipleDiceType.sides))
        }
        
        let roll = MultipleDiceRoll(
            diceType: multipleDiceType,
            quantity: multipleDiceQuantity,
            results: results
        )
        
        multipleDiceResult = roll
        rolling = false
        
        audioManager.playDiceRoll()
        
        let hasCritical = results.contains(multipleDiceType.sides)
        let hasFumble = results.contains(1)
        
        if hasCritical {
            audioManager.playCritical()
        } else if hasFumble {
            audioManager.playFumble()
        }
    }
}
