
import Foundation
import SwiftUI

// MARK: - Campaign Models

struct Campaign: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var createdDate: Date
    var lastModified: Date
    var isActive: Bool
    
    init(id: UUID = UUID(), name: String, description: String = "", isActive: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.createdDate = Date()
        self.lastModified = Date()
        self.isActive = isActive
    }
}

struct NPC: Identifiable, Codable {
    let id: UUID
    var campaignId: UUID
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
    
    init(
        id: UUID = UUID(),
        campaignId: UUID,
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
        self.campaignId = campaignId
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
        if healthPercentage > 0.6 { return .green }
        if healthPercentage > 0.3 { return .orange }
        return .red
    }
}

struct InventoryItem: Identifiable, Codable {
    let id: UUID
    var campaignId: UUID
    var name: String
    var description: String
    var quantity: Int
    var category: ItemCategory
    var value: Int // in gold pieces
    var weight: Double // in pounds
    var isEquipped: Bool
    var notes: String
    
    init(
        id: UUID = UUID(),
        campaignId: UUID,
        name: String,
        description: String = "",
        quantity: Int = 1,
        category: ItemCategory = .misc,
        value: Int = 0,
        weight: Double = 0,
        isEquipped: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.campaignId = campaignId
        self.name = name
        self.description = description
        self.quantity = quantity
        self.category = category
        self.value = value
        self.weight = weight
        self.isEquipped = isEquipped
        self.notes = notes
    }
    
    var totalValue: Int {
        value * quantity
    }
    
    var totalWeight: Double {
        weight * Double(quantity)
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
    
    var color: Color {
        switch self {
        case .weapon: return .red
        case .armor: return .blue
        case .potion: return .green
        case .scroll: return .purple
        case .misc: return .gray
        case .quest: return .yellow
        case .treasure: return .orange
        }
    }
}

// MARK: - Campaign Manager

class CampaignManager: ObservableObject {
    static let shared = CampaignManager()
    
    @Published var campaigns: [Campaign] = []
    @Published var npcs: [NPC] = []
    @Published var inventory: [InventoryItem] = []
    
    private let campaignsKey = "campaigns"
    private let npcsKey = "npcs"
    private let inventoryKey = "inventory"
    
    init() {
        loadData()
    }
    
    // MARK: - Campaign Management
    
    func addCampaign(_ campaign: Campaign) {
        campaigns.append(campaign)
        saveCampaigns()
    }
    
    func updateCampaign(_ campaign: Campaign) {
        if let index = campaigns.firstIndex(where: { $0.id == campaign.id }) {
            var updated = campaign
            updated.lastModified = Date()
            campaigns[index] = updated
            saveCampaigns()
        }
    }
    
    func deleteCampaign(_ campaign: Campaign) {
        campaigns.removeAll { $0.id == campaign.id }
        npcs.removeAll { $0.campaignId == campaign.id }
        inventory.removeAll { $0.campaignId == campaign.id }
        saveCampaigns()
        saveNPCs()
        saveInventory()
    }
    
    func setActiveCampaign(_ campaign: Campaign) {
        for i in campaigns.indices {
            campaigns[i].isActive = campaigns[i].id == campaign.id
        }
        saveCampaigns()
    }
    
    var activeCampaign: Campaign? {
        campaigns.first { $0.isActive }
    }
    
    // MARK: - NPC Management
    
    func addNPC(_ npc: NPC) {
        npcs.append(npc)
        saveNPCs()
    }
    
    func updateNPC(_ npc: NPC) {
        if let index = npcs.firstIndex(where: { $0.id == npc.id }) {
            npcs[index] = npc
            saveNPCs()
        }
    }
    
    func deleteNPC(_ npc: NPC) {
        npcs.removeAll { $0.id == npc.id }
        saveNPCs()
    }
    
    func npcs(for campaignId: UUID) -> [NPC] {
        npcs.filter { $0.campaignId == campaignId }
    }
    
    // MARK: - Inventory Management
    
    func addItem(_ item: InventoryItem) {
        inventory.append(item)
        saveInventory()
    }
    
    func updateItem(_ item: InventoryItem) {
        if let index = inventory.firstIndex(where: { $0.id == item.id }) {
            inventory[index] = item
            saveInventory()
        }
    }
    
    func deleteItem(_ item: InventoryItem) {
        inventory.removeAll { $0.id == item.id }
        saveInventory()
    }
    
    func items(for campaignId: UUID) -> [InventoryItem] {
        inventory.filter { $0.campaignId == campaignId }
    }
    
    func totalValue(for campaignId: UUID) -> Int {
        items(for: campaignId).reduce(0) { $0 + $1.totalValue }
    }
    
    func totalWeight(for campaignId: UUID) -> Double {
        items(for: campaignId).reduce(0) { $0 + $1.totalWeight }
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: campaignsKey),
           let decoded = try? JSONDecoder().decode([Campaign].self, from: data) {
            campaigns = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: npcsKey),
           let decoded = try? JSONDecoder().decode([NPC].self, from: data) {
            npcs = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: inventoryKey),
           let decoded = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            inventory = decoded
        }
    }
    
    private func saveCampaigns() {
        if let encoded = try? JSONEncoder().encode(campaigns) {
            UserDefaults.standard.set(encoded, forKey: campaignsKey)
        }
    }
    
    private func saveNPCs() {
        if let encoded = try? JSONEncoder().encode(npcs) {
            UserDefaults.standard.set(encoded, forKey: npcsKey)
        }
    }
    
    private func saveInventory() {
        if let encoded = try? JSONEncoder().encode(inventory) {
            UserDefaults.standard.set(encoded, forKey: inventoryKey)
        }
    }
}
