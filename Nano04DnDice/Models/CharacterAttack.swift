import Foundation

struct CharacterAttack: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var attackBonus: Int
    var damageDice: String // e.g., "1d8"
    var damageBonus: Int
    var damageType: String // e.g., "Slashing"
    
    init(id: UUID = UUID(), name: String, attackBonus: Int = 0, damageDice: String = "1d6", damageBonus: Int = 0, damageType: String = "Slashing") {
        self.id = id
        self.name = name
        self.attackBonus = attackBonus
        self.damageDice = damageDice
        self.damageBonus = damageBonus
        self.damageType = damageType
    }
}
