
import Foundation
import SwiftData
import SwiftUI

@Model
final class Campaign {
    @Attribute(.unique) var id: UUID
    var name: String
    var campaignDescription: String
    var createdDate: Date
    var lastModified: Date
    var isActive: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \NPC.campaign) 
    var npcs: [NPC] = []
    
    @Relationship(deleteRule: .cascade, inverse: \InventoryItem.campaign) 
    var inventory: [InventoryItem] = []
    
    init(id: UUID = UUID(), name: String, campaignDescription: String = "", isActive: Bool = false) {
        self.id = id
        self.name = name
        self.campaignDescription = campaignDescription
        self.createdDate = Date()
        self.lastModified = Date()
        self.isActive = isActive
    }
}

@Model
final class NPC {
    @Attribute(.unique) var id: UUID
    var name: String
    var race: String
    var characterClass: String
    var level: Int
    var armorClass: Int
    var hitPoints: Int
    var maxHitPoints: Int
    var notes: String
    var imageData: Data?
    var isAlly: Bool
    
    var campaign: Campaign?
    
    init(
        id: UUID = UUID(),
        name: String,
        race: String = "",
        characterClass: String = "",
        level: Int = 1,
        armorClass: Int = 10,
        hitPoints: Int = 10,
        maxHitPoints: Int = 10,
        notes: String = "",
        imageData: Data? = nil,
        isAlly: Bool = true
    ) {
        self.id = id
        self.name = name
        self.race = race
        self.characterClass = characterClass
        self.level = level
        self.armorClass = armorClass
        self.hitPoints = hitPoints
        self.maxHitPoints = maxHitPoints
        self.notes = notes
        self.imageData = imageData
        self.isAlly = isAlly
    }
    
    var healthPercentage: Double {
        guard maxHitPoints > 0 else { return 0 }
        return Double(hitPoints) / Double(maxHitPoints)
    }
    
    var healthColor: Color {
        let percentage = healthPercentage
        if percentage > 0.7 { return .green }
        if percentage > 0.3 { return .orange }
        return .red
    }
}

@Model
final class InventoryItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var itemDescription: String
    var quantity: Int
    var categoryString: String
    var value: Int
    var weight: Double
    var isEquipped: Bool
    var notes: String
    
    var campaign: Campaign?
    
    init(
        id: UUID = UUID(),
        name: String,
        itemDescription: String = "",
        quantity: Int = 1,
        category: ItemCategory = .misc,
        value: Int = 0,
        weight: Double = 0,
        isEquipped: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.categoryString = category.rawValue
        self.value = value
        self.weight = weight
        self.isEquipped = isEquipped
        self.notes = notes
    }
    
    var category: ItemCategory {
        get { ItemCategory(rawValue: categoryString) ?? .misc }
        set { categoryString = newValue.rawValue }
    }
}

enum ItemCategory: String, Codable, CaseIterable {
    case weapon = "Weapon"
    case armor = "Armor"
    case potion = "Potion"
    case scroll = "Scroll"
    case misc = "Miscellaneous"
    case quest = "Quest Item"
    case treasure = "Treasure"
    
    var icon: String {
        switch self {
        case .weapon: return "sword.fill"
        case .armor: return "shield.fill"
        case .potion: return "flask.fill"
        case .scroll: return "scroll.fill"
        case .misc: return "bag.fill"
        case .quest: return "star.fill"
        case .treasure: return "diamond.fill"
        }
    }
}
