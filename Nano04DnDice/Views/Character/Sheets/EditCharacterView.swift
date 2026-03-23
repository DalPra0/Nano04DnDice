
import SwiftUI
import SwiftData

struct EditCharacterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var character: PlayerCharacter
    
    @State private var showDeleteAlert = false
    
    private let classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard"]
    private let races = ["Dragonborn", "Dwarf", "Elf", "Gnome", "Half-Elf", "Half-Orc", "Halfling", "Human", "Tiefling"]
    
    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Name", text: $character.name)
                
                Picker("Class", selection: $character.characterClass) {
                    ForEach(classes, id: \.self) { classType in
                        Text(classType).tag(classType)
                    }
                }
                
                Picker("Race", selection: $character.race) {
                    ForEach(races, id: \.self) { raceType in
                        Text(raceType).tag(raceType)
                    }
                }
                
                Stepper("Level: \(character.level)", value: $character.level, in: 1...20)
                HStack {
                    Text("Experience")
                    Spacer()
                    TextField("XP", value: $character.experiencePoints, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section("Ability Scores") {
                Stepper("Strength: \(character.strength)", value: $character.strength, in: 3...30)
                Stepper("Dexterity: \(character.dexterity)", value: $character.dexterity, in: 3...30)
                Stepper("Constitution: \(character.constitution)", value: $character.constitution, in: 3...30)
                Stepper("Intelligence: \(character.intelligence)", value: $character.intelligence, in: 3...30)
                Stepper("Wisdom: \(character.wisdom)", value: $character.wisdom, in: 3...30)
                Stepper("Charisma: \(character.charisma)", value: $character.charisma, in: 3...30)
            }
            
            Section("Combat Stats") {
                Stepper("Armor Class: \(character.armorClass)", value: $character.armorClass, in: 1...40)
                Stepper("Current HP: \(character.hitPoints)", value: $character.hitPoints, in: 0...character.maxHitPoints)
                Stepper("Max HP: \(character.maxHitPoints)", value: $character.maxHitPoints, in: 1...999)
                Stepper("Speed: \(character.speed)", value: $character.speed, in: 0...100)
                Stepper("Proficiency Bonus: \(character.proficiencyBonus)", value: $character.proficiencyBonus, in: 1...10)
                
                Picker("Spellcasting Ability", selection: Binding(get: { character.spellcastingAbility ?? "INT" }, set: { character.spellcastingAbility = $0 })) {
                    Text("Intelligence").tag("INT")
                    Text("Wisdom").tag("WIS")
                    Text("Charisma").tag("CHA")
                    Text("None").tag("NONE")
                }
            }
            
            Section("Equipment") {
                TextField("Weapon", text: $character.equippedWeapon)
                TextField("Armor", text: $character.equippedArmor)
            }
            
            Section("Backstory") {
                TextEditor(text: $character.backstory)
                    .frame(height: 100)
            }
            
            Section("Notes") {
                TextEditor(text: $character.notes)
                    .frame(height: 100)
            }
            
            Section {
                Button(role: .destructive, action: { showDeleteAlert = true }) {
                    Label("Delete Character", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Edit Character")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .alert("Delete Character?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(character)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
