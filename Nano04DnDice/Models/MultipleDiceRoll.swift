import Foundation

struct MultipleDiceRoll: Identifiable, Equatable {
    let id = UUID()
    let diceType: DiceType
    let quantity: Int
    let results: [Int]
    
    var total: Int {
        results.reduce(0, +)
    }
    
    var average: Double {
        guard !results.isEmpty else { return 0.0 }
        return Double(total) / Double(results.count)
    }
    
    var displayName: String {
        "\(quantity)D\(diceType.sides)"
    }
}

enum MultipleDicePreset: String, CaseIterable, Identifiable {
    case twoD6 = "2D6"
    case threeD6 = "3D6"
    case fourD6 = "4D6"
    case eightD6 = "8D6"
    case twoD8 = "2D8"
    case threeD8 = "3D8"
    case twoD10 = "2D10"
    case twoD20 = "2D20"
    
    var id: String { rawValue }
    
    var diceType: DiceType {
        switch self {
        case .twoD6, .threeD6, .fourD6, .eightD6:
            return .d6
        case .twoD8, .threeD8:
            return .d8
        case .twoD10:
            return .d10
        case .twoD20:
            return .d20
        }
    }
    
    var quantity: Int {
        switch self {
        case .twoD6, .twoD8, .twoD10, .twoD20:
            return 2
        case .threeD6, .threeD8:
            return 3
        case .fourD6:
            return 4
        case .eightD6:
            return 8
        }
    }
}
