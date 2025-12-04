import SwiftUI
import Foundation
import SwiftUI
import Combine

struct DiceRollEntry: Identifiable, Codable {
    let id: UUID
    let diceType: DiceType
    let result: Int
    let secondResult: Int?
    let rollMode: RollMode
    let proficiencyBonus: Int
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id, result, secondResult, rollMode, proficiencyBonus, timestamp
        case diceTypeName, diceTypeSides
    }
    
    init(diceType: DiceType, result: Int, secondResult: Int? = nil, rollMode: RollMode = .normal, proficiencyBonus: Int = 0) {
        self.id = UUID()
        self.diceType = diceType
        self.result = result
        self.secondResult = secondResult
        self.rollMode = rollMode
        self.proficiencyBonus = proficiencyBonus
        self.timestamp = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        result = try container.decode(Int.self, forKey: .result)
        secondResult = try container.decodeIfPresent(Int.self, forKey: .secondResult)
        rollMode = try container.decode(RollMode.self, forKey: .rollMode)
        proficiencyBonus = try container.decode(Int.self, forKey: .proficiencyBonus)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        let sides = try container.decode(Int.self, forKey: .diceTypeSides)
        
        if sides == 4 {
            diceType = .d4
        } else if sides == 6 {
            diceType = .d6
        } else if sides == 8 {
            diceType = .d8
        } else if sides == 10 {
            diceType = .d10
        } else if sides == 12 {
            diceType = .d12
        } else if sides == 20 {
            diceType = .d20
        } else {
            diceType = .custom(sides: sides)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(result, forKey: .result)
        try container.encodeIfPresent(secondResult, forKey: .secondResult)
        try container.encode(rollMode, forKey: .rollMode)
        try container.encode(proficiencyBonus, forKey: .proficiencyBonus)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(diceType.name, forKey: .diceTypeName)
        try container.encode(diceType.sides, forKey: .diceTypeSides)
    }
    
    var isCritical: Bool {
        let baseRoll = result - proficiencyBonus
        return baseRoll == diceType.sides
    }
    
    var isFumble: Bool {
        let baseRoll = result - proficiencyBonus
        return baseRoll == 1
    }
    
    var displayText: String {
        var text = "\(diceType.name): \(result)"
        if let second = secondResult {
            text += " [\(second)]"
        }
        if proficiencyBonus != 0 {
            text += " (+\(proficiencyBonus))"
        }
        return text
    }
}

class DiceRollHistoryManager: ObservableObject {
    static let shared = DiceRollHistoryManager()
    
    @Published private(set) var history: [DiceRollEntry] = []
    
    private let maxHistoryCount = 50
    private let userDefaultsKey = "diceRollHistory"
    
    init() {
        loadHistory()
    }
    
    func addRoll(_ entry: DiceRollEntry) {
        history.insert(entry, at: 0)
        
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    func getStatistics() -> RollStatistics {
        RollStatistics(rolls: history)
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([DiceRollEntry].self, from: data) {
            history = decoded
        }
    }
}

struct RollStatistics {
    let totalRolls: Int
    let criticals: Int
    let fumbles: Int
    let averageRoll: Double
    let highestRoll: Int
    let lowestRoll: Int
    let mostUsedDice: String
    
    init(rolls: [DiceRollEntry]) {
        totalRolls = rolls.count
        criticals = rolls.filter { $0.isCritical }.count
        fumbles = rolls.filter { $0.isFumble }.count
        
        if !rolls.isEmpty {
            let baseRolls = rolls.map { $0.result - $0.proficiencyBonus }
            averageRoll = Double(baseRolls.reduce(0, +)) / Double(baseRolls.count)
            highestRoll = baseRolls.max() ?? 0
            lowestRoll = baseRolls.min() ?? 0
            
            let diceCount = Dictionary(grouping: rolls, by: { $0.diceType.name })
                .mapValues { $0.count }
            mostUsedDice = diceCount.max(by: { $0.value < $1.value })?.key ?? "N/A"
        } else {
            averageRoll = 0
            highestRoll = 0
            lowestRoll = 0
            mostUsedDice = "N/A"
        }
    }
}
