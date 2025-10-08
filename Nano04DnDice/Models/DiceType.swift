//
//  DiceType.swift
//  Nano04DnDice
//
//  Model - Tipos de dados disponíveis
//

import Foundation

enum DiceType: Hashable {
    case d4, d6, d8, d10, d12, d20
    case custom(sides: Int)
    
    static var allCases: [DiceType] = [.d4, .d6, .d8, .d10, .d12, .d20]
    
    var sides: Int {
        switch self {
        case .d4: return 4
        case .d6: return 6
        case .d8: return 8
        case .d10: return 10
        case .d12: return 12
        case .d20: return 20
        case .custom(let sides): return sides
        }
    }
    
    var name: String {
        "D\(sides)"
    }
    
    var shortName: String {
        name
    }
    
    var isCustom: Bool {
        if case .custom = self {
            return true
        }
        return false
    }
}
