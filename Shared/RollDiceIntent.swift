//
//  RollDiceIntent.swift
//  DnDiceWidget
//
//  App Intents for interactive widgets (iOS 17+)
//

import AppIntents
import WidgetKit

// MARK: - Roll Dice Intent (Interactive Widget)
struct RollDiceIntent: AppIntent {
    static var title: LocalizedStringResource = "Roll Dice"
    static var description = IntentDescription("Roll a random dice")
    static var openAppWhenRun: Bool = true  // Open app when Siri runs this
    
    // Siri suggestions for easy discovery
    static var parameterSummary: some ParameterSummary {
        Summary("Roll a \(\.$diceType)")
    }
    
    @Parameter(title: "Dice Type", default: .d20)
    var diceType: DiceTypeEntity
    
    init() {
        self.diceType = .d20
    }
    
    init(diceType: DiceTypeEntity) {
        self.diceType = diceType
    }
    
    func perform() async throws -> some IntentResult {
        // Roll the dice
        let result = Int.random(in: 1...diceType.sides)
        
        // Save to App Group (shared with main app and Watch)
        if let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroup) {
            sharedDefaults.set(result, forKey: AppConstants.UserDefaultsKeys.lastDiceResult)
            sharedDefaults.set(diceType.displayName, forKey: AppConstants.UserDefaultsKeys.lastDiceType)
            sharedDefaults.set(Date(), forKey: AppConstants.UserDefaultsKeys.lastRollDate)
        }
        
        // Reload all widgets
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

// MARK: - Dice Type Entity (for App Intents)
enum DiceTypeEntity: String, AppEnum {
    case d4 = "D4"
    case d6 = "D6"
    case d8 = "D8"
    case d10 = "D10"
    case d12 = "D12"
    case d20 = "D20"
    case d100 = "D100"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Dice Type"
    }
    
    static var caseDisplayRepresentations: [DiceTypeEntity: DisplayRepresentation] {
        [
            .d4: "D4 (4 sides)",
            .d6: "D6 (6 sides)",
            .d8: "D8 (8 sides)",
            .d10: "D10 (10 sides)",
            .d12: "D12 (12 sides)",
            .d20: "D20 (20 sides)",
            .d100: "D100 (100 sides)"
        ]
    }
    
    var sides: Int {
        switch self {
        case .d4: return 4
        case .d6: return 6
        case .d8: return 8
        case .d10: return 10
        case .d12: return 12
        case .d20: return 20
        case .d100: return 100
        }
    }
    
    var displayName: String {
        self.rawValue
    }
}

// MARK: - Quick Roll Intent (for Widget Control)
struct QuickRollD20Intent: AppIntent {
    static var title: LocalizedStringResource = "Quick Roll D20"
    static var description = IntentDescription("Quickly roll a D20")
    static var openAppWhenRun: Bool = true  // Open app when Siri runs this
    
    // Siri suggestion
    static var parameterSummary: some ParameterSummary {
        Summary("Roll a D20")
    }
    
    func perform() async throws -> some IntentResult {
        let result = Int.random(in: 1...20)
        
        if let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroup) {
            sharedDefaults.set(result, forKey: AppConstants.UserDefaultsKeys.lastDiceResult)
            sharedDefaults.set("D20", forKey: AppConstants.UserDefaultsKeys.lastDiceType)
            sharedDefaults.set(Date(), forKey: AppConstants.UserDefaultsKeys.lastRollDate)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}
