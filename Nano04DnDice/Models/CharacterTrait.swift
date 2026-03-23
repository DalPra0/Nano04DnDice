import Foundation

struct CharacterTrait: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var descriptionText: String
    var source: String // e.g., "Class", "Race", "Feat"
    
    init(id: UUID = UUID(), name: String, descriptionText: String, source: String = "Class") {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.source = source
    }
}
