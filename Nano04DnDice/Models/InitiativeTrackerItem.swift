import Foundation

struct InitiativeTrackerItem: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var initiative: Int
    var isAlly: Bool
    var hitPoints: Int
    var maxHitPoints: Int
    
    init(id: UUID = UUID(), name: String, initiative: Int, isAlly: Bool = false, hitPoints: Int = 0, maxHitPoints: Int = 0) {
        self.id = id
        self.name = name
        self.initiative = initiative
        self.isAlly = isAlly
        self.hitPoints = hitPoints
        self.maxHitPoints = maxHitPoints
    }
}
