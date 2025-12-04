
import SwiftUI

// MARK: - Add Campaign

struct AddCampaignView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CampaignManager.shared
    
    @State private var name = ""
    @State private var description = ""
    @State private var setAsActive = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Campaign Details") {
                    TextField("Campaign Name", text: $name)
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Description (optional)")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section {
                    Toggle("Set as Active Campaign", isOn: $setAsActive)
                }
            }
            .navigationTitle("New Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createCampaign()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func createCampaign() {
        let campaign = Campaign(name: name, description: description, isActive: setAsActive)
        manager.addCampaign(campaign)
        
        if setAsActive {
            manager.setActiveCampaign(campaign)
        }
        
        dismiss()
    }
}

// MARK: - Edit Campaign

struct EditCampaignView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CampaignManager.shared
    
    let campaign: Campaign
    @State private var name = ""
    @State private var description = ""
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Campaign Details") {
                    TextField("Campaign Name", text: $name)
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section("Stats") {
                    HStack {
                        Text("NPCs")
                        Spacer()
                        Text("\(manager.npcs(for: campaign.id).count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Items")
                        Spacer()
                        Text("\(manager.items(for: campaign.id).count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Value")
                        Spacer()
                        Text("\(manager.totalValue(for: campaign.id)) gp")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label("Delete Campaign", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCampaign()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("Delete Campaign?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    manager.deleteCampaign(campaign)
                    dismiss()
                }
            } message: {
                Text("This will delete all NPCs and inventory items associated with this campaign. This action cannot be undone.")
            }
        }
        .onAppear {
            name = campaign.name
            description = campaign.description
        }
    }
    
    private func saveCampaign() {
        var updated = campaign
        updated.name = name
        updated.description = description
        manager.updateCampaign(updated)
        dismiss()
    }
}

// MARK: - Add NPC

struct AddNPCView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CampaignManager.shared
    
    let campaignId: UUID
    
    @State private var name = ""
    @State private var race = ""
    @State private var characterClass = ""
    @State private var level = 1
    @State private var armorClass = 10
    @State private var hitPoints = 10
    @State private var maxHitPoints = 10
    @State private var notes = ""
    @State private var isAlly = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    
                    Toggle("Ally", isOn: $isAlly)
                    
                    TextField("Race", text: $race)
                    TextField("Class", text: $characterClass)
                    
                    Stepper("Level: \(level)", value: $level, in: 1...20)
                }
                
                Section("Combat Stats") {
                    Stepper("Armor Class: \(armorClass)", value: $armorClass, in: 1...30)
                    
                    Stepper("Hit Points: \(hitPoints)", value: $hitPoints, in: 0...999)
                    
                    Stepper("Max HP: \(maxHitPoints)", value: $maxHitPoints, in: 1...999)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New NPC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createNPC()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func createNPC() {
        let npc = NPC(
            campaignId: campaignId,
            name: name,
            race: race,
            characterClass: characterClass,
            level: level,
            armorClass: armorClass,
            hitPoints: hitPoints,
            maxHitPoints: maxHitPoints,
            notes: notes,
            isAlly: isAlly
        )
        manager.addNPC(npc)
        dismiss()
    }
}

// MARK: - Edit NPC

struct EditNPCView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CampaignManager.shared
    
    let npc: NPC
    
    @State private var name = ""
    @State private var race = ""
    @State private var characterClass = ""
    @State private var level = 1
    @State private var armorClass = 10
    @State private var hitPoints = 10
    @State private var maxHitPoints = 10
    @State private var notes = ""
    @State private var isAlly = true
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    
                    Toggle("Ally", isOn: $isAlly)
                    
                    TextField("Race", text: $race)
                    TextField("Class", text: $characterClass)
                    
                    Stepper("Level: \(level)", value: $level, in: 1...20)
                }
                
                Section("Combat Stats") {
                    Stepper("Armor Class: \(armorClass)", value: $armorClass, in: 1...30)
                    
                    HStack {
                        Stepper("HP: \(hitPoints)/\(maxHitPoints)", value: $hitPoints, in: 0...maxHitPoints)
                    }
                    
                    Stepper("Max HP: \(maxHitPoints)", value: $maxHitPoints, in: 1...999)
                    
                    // Quick HP buttons
                    HStack {
                        Button(action: { hitPoints = maxHitPoints }) {
                            Label("Full Heal", systemImage: "heart.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                        
                        Button(action: { hitPoints = max(0, hitPoints - 5) }) {
                            Label("Take 5", systemImage: "heart.slash")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label("Delete NPC", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit NPC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNPC()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("Delete NPC?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    manager.deleteNPC(npc)
                    dismiss()
                }
            }
        }
        .onAppear {
            name = npc.name
            race = npc.race
            characterClass = npc.characterClass
            level = npc.level
            armorClass = npc.armorClass
            hitPoints = npc.hitPoints
            maxHitPoints = npc.maxHitPoints
            notes = npc.notes
            isAlly = npc.isAlly
        }
    }
    
    private func saveNPC() {
        var updated = npc
        updated.name = name
        updated.race = race
        updated.characterClass = characterClass
        updated.level = level
        updated.armorClass = armorClass
        updated.hitPoints = hitPoints
        updated.maxHitPoints = maxHitPoints
        updated.notes = notes
        updated.isAlly = isAlly
        manager.updateNPC(updated)
        dismiss()
    }
}

// MARK: - Add Inventory Item

struct AddInventoryItemView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CampaignManager.shared
    
    let campaignId: UUID
    
    @State private var name = ""
    @State private var description = ""
    @State private var quantity = 1
    @State private var category: ItemCategory = .misc
    @State private var value = 0
    @State private var weight = 0.0
    @State private var isEquipped = false
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    
                    TextField("Description", text: $description)
                    
                    Toggle("Equipped", isOn: $isEquipped)
                }
                
                Section("Quantity & Value") {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)
                    
                    Stepper("Value: \(value) gp", value: $value, in: 0...999999)
                    
                    HStack {
                        Text("Weight (lbs)")
                        Spacer()
                        TextField("0.0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func createItem() {
        let item = InventoryItem(
            campaignId: campaignId,
            name: name,
            description: description,
            quantity: quantity,
            category: category,
            value: value,
            weight: weight,
            isEquipped: isEquipped,
            notes: notes
        )
        manager.addItem(item)
        dismiss()
    }
}

// MARK: - Edit Inventory Item

struct EditInventoryItemView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CampaignManager.shared
    
    let item: InventoryItem
    
    @State private var name = ""
    @State private var description = ""
    @State private var quantity = 1
    @State private var category: ItemCategory = .misc
    @State private var value = 0
    @State private var weight = 0.0
    @State private var isEquipped = false
    @State private var notes = ""
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    
                    TextField("Description", text: $description)
                    
                    Toggle("Equipped", isOn: $isEquipped)
                }
                
                Section("Quantity & Value") {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)
                    
                    Stepper("Value: \(value) gp", value: $value, in: 0...999999)
                    
                    HStack {
                        Text("Weight (lbs)")
                        Spacer()
                        TextField("0.0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Total Value")
                        Spacer()
                        Text("\(value * quantity) gp")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Weight")
                        Spacer()
                        Text(String(format: "%.1f lbs", weight * Double(quantity)))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
                
                Section {
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label("Delete Item", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("Delete Item?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    manager.deleteItem(item)
                    dismiss()
                }
            }
        }
        .onAppear {
            name = item.name
            description = item.description
            quantity = item.quantity
            category = item.category
            value = item.value
            weight = item.weight
            isEquipped = item.isEquipped
            notes = item.notes
        }
    }
    
    private func saveItem() {
        var updated = item
        updated.name = name
        updated.description = description
        updated.quantity = quantity
        updated.category = category
        updated.value = value
        updated.weight = weight
        updated.isEquipped = isEquipped
        updated.notes = notes
        manager.updateItem(updated)
        dismiss()
    }
}

#Preview {
    AddCampaignView()
}
