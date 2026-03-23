import Foundation

struct CharacterSpell: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var level: Int // 0 for Cantrip
    var castingTime: String
    var range: String
    var components: String
    var duration: String
    var descriptionText: String
    var isPrepared: Bool
    
    init(id: UUID = UUID(), name: String, level: Int, castingTime: String = "1 Action", range: String = "60 ft", components: String = "V, S", duration: String = "Instantaneous", descriptionText: String = "", isPrepared: Bool = true) {
        self.id = id
        self.name = name
        self.level = level
        self.castingTime = castingTime
        self.range = range
        self.components = components
        self.duration = duration
        self.descriptionText = descriptionText
        self.isPrepared = isPrepared
    }
}

struct SpellSlotStatus: Codable {
    var total: Int
    var used: Int
    
    init(total: Int = 0, used: Int = 0) {
        self.total = total
        self.used = used
    }
}
