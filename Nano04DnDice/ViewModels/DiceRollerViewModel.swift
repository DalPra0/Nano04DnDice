
import SwiftUI
import Combine

private enum ViewModelConstants {
    static let appGroup = "group.com.DalPra.DiceAndDragons"
    
    enum UserDefaultsKeys {
        static let lastDiceResult = "lastDiceResult"
        static let lastDiceType = "lastDiceType"
        static let lastRollDate = "lastRollDate"
    }
}

@MainActor
class DiceRollerViewModel: ObservableObject {
    // MARK: - Dice State
    /// Current rolling animation state
    @Published var rolling = false
    /// Primary dice roll result (or selected result in advantage/disadvantage)
    @Published var result: Int?
    /// Secondary result for advantage/disadvantage rolls
    @Published var secondResult: Int?
    /// Display value for WebView animation
    @Published var currentRoll = 1
    /// Ambient glow animation intensity
    @Published var glowIntensity: Double = 0.3
    /// Currently selected dice type (d4-d100 or custom)
    @Published var selectedDiceType: DiceType = .d20
    /// Roll modifier: normal, blessed (advantage), or cursed (disadvantage)
    @Published var rollMode: RollMode = .normal
    
    // MARK: - Dice Configuration
    @Published var customDiceSides: String = "20"
    @Published var proficiencyBonus: Int = 0
    
    // MARK: - Multiple Dice
    @Published var multipleDiceQuantity: Int = 2
    @Published var multipleDiceType: DiceType = .d6
    @Published var multipleDiceResult: MultipleDiceRoll?
    
    // MARK: - Navigation (Extracted to separate state)
    @Published var navigation = NavigationState()
    
    // MARK: - Dependencies
    private let audioManager = AudioManager.shared
    private let historyManager = DiceRollHistoryManager.shared
    
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
            navigation.showCustomDice = false
        }
    }
    
    /// Trigger a dice roll with animation and audio
    /// Handles advantage/disadvantage rolls by generating 2 results
    /// Thread-safe: @MainActor ensures UI updates on main thread
    func rollDice() {
        guard !rolling else {
            print("[Dice] Already rolling, ignoring tap")
            return
        }
        
        // Lock state immediately to prevent race conditions
        rolling = true
        result = nil
        secondResult = nil
        
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()
        
        // Generate roll values
        let firstRoll = Int.random(in: 1...selectedDiceType.sides)
        var finalRoll = firstRoll
        var secondRollValue: Int? = nil
        
        // Handle advantage/disadvantage
        if rollMode != .normal {
            let secondRoll = Int.random(in: 1...selectedDiceType.sides)
            secondRollValue = secondRoll
            
            if rollMode == .blessed {
                finalRoll = max(firstRoll, secondRoll)
            } else { // cursed
                finalRoll = min(firstRoll, secondRoll)
            }
        }
        
        // Store values for WebView animation
        currentRoll = finalRoll
        secondResult = secondRollValue
        
        // Play sound
        audioManager.playDiceRoll()
        
        // Animate glow
        withAnimation(.easeInOut(duration: 0.3)) {
            glowIntensity = 1.0
        }
    }
    
    func handleRollComplete(_ finalResult: Int) {
        // Validate result is within dice range
        guard finalResult >= 1 && finalResult <= selectedDiceType.sides else {
            print("⚠️ Invalid roll result \(finalResult) for d\(selectedDiceType.sides)")
            rolling = false
            return
        }
        
        // Calculate final result with proficiency bonus
        let totalResult = finalResult + proficiencyBonus
        result = totalResult
        rolling = false
        
        // Save to history
        let entry = DiceRollEntry(
            diceType: selectedDiceType,
            result: totalResult,
            secondResult: secondResult,
            rollMode: rollMode,
            proficiencyBonus: proficiencyBonus
        )
        historyManager.addRoll(entry)
        
        if let sharedDefaults = UserDefaults(suiteName: ViewModelConstants.appGroup) {
            sharedDefaults.set(finalResult + proficiencyBonus, forKey: ViewModelConstants.UserDefaultsKeys.lastDiceResult)
            sharedDefaults.set(selectedDiceType.name, forKey: ViewModelConstants.UserDefaultsKeys.lastDiceType)
            sharedDefaults.set(Date(), forKey: ViewModelConstants.UserDefaultsKeys.lastRollDate)
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            glowIntensity = 0.3
        }
        
        if finalResult == selectedDiceType.sides {
            audioManager.playCritical()
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
        } else if finalResult == 1 {
            audioManager.playFumble()
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.error)
        } else {
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
        }
    }
    
    func continueAfterResult() {
        result = nil
        secondResult = nil
        multipleDiceResult = nil
        currentRoll = Int.random(in: 1...selectedDiceType.sides)
    }
    
    func rollMultipleDice() {
        guard !rolling else {
            print("[Dice] Already rolling, ignoring tap")
            return
        }
        
        rolling = true
        multipleDiceResult = nil
        
        let haptic = UIImpactFeedbackGenerator(style: .heavy)
        haptic.impactOccurred()
        
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
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
        } else if hasFumble {
            audioManager.playFumble()
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.error)
        } else {
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
        }
    }
}
