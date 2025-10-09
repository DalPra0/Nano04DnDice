//
//  RollMode.swift
//  Nano04DnDice
//
//  Model - Roll Modes (Normal/Blessed/Cursed)
//

import Foundation

enum RollMode: String, CaseIterable {
    case normal = "Normal"
    case blessed = "Blessed"
    case cursed = "Cursed"
    
    var displayName: String {
        return self.rawValue
    }
}
