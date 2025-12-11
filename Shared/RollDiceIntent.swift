import Foundation
import AppIntents
import WidgetKit

private enum IntentConstants {
    static let appGroup = "group.com.DalPra.DiceAndDragons"
    
    enum UserDefaultsKeys {
        static let lastDiceResult = "lastDiceResult"
        static let lastDiceType = "lastDiceType"
        static let lastRollDate = "lastRollDate"
    }
}

struct RollDiceIntent: AppIntent {
    static var title: LocalizedStringResource = "Roll Dice"
    static var description = IntentDescription("Roll a random dice")
    static var openAppWhenRun: Bool = false
    
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
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = Int.random(in: 1...diceType.sides)
        
        if let sharedDefaults = UserDefaults(suiteName: IntentConstants.appGroup) {
            sharedDefaults.set(result, forKey: IntentConstants.UserDefaultsKeys.lastDiceResult)
            sharedDefaults.set(diceType.displayName, forKey: IntentConstants.UserDefaultsKeys.lastDiceType)
            sharedDefaults.set(Date(), forKey: IntentConstants.UserDefaultsKeys.lastRollDate)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result(dialog: "You rolled a \(diceType.displayName) and got \(result)")
    }
}

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

struct QuickRollD20Intent: AppIntent {
    static var title: LocalizedStringResource = "Quick Roll D20"
    static var description = IntentDescription("Quickly roll a D20")
    static var openAppWhenRun: Bool = false
    
    static var parameterSummary: some ParameterSummary {
        Summary("Roll a D20")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = Int.random(in: 1...20)
        
        if let sharedDefaults = UserDefaults(suiteName: IntentConstants.appGroup) {
            sharedDefaults.set(result, forKey: IntentConstants.UserDefaultsKeys.lastDiceResult)
            sharedDefaults.set("D20", forKey: IntentConstants.UserDefaultsKeys.lastDiceType)
            sharedDefaults.set(Date(), forKey: IntentConstants.UserDefaultsKeys.lastRollDate)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result(dialog: "You rolled a D20 and got \(result)")
    }
}
