
import SwiftUI

struct EditCharacterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CharacterManager.shared
    
    let character: PlayerCharacter
    
    @State private var name = ""
    @State private var characterClass = ""
    @State private var race = ""
    @State private var level = 1
    @State private var experiencePoints = 0
    
    @State private var strength = 10
    @State private var dexterity = 10
    @State private var constitution = 10
    @State private var intelligence = 10
    @State private var wisdom = 10
    @State private var charisma = 10
    
    @State private var armorClass = 10
    @State private var hitPoints = 10
    @State private var maxHitPoints = 10
    @State private var speed = 30
    @State private var proficiencyBonus = 2
    
    @State private var equippedWeapon = ""
    @State private var equippedArmor = ""
    @State private var notes = ""
    @State private var backstory = ""
    
    @State private var selectedSkills: Set<Skill> = []
    @State private var selectedSavingThrows: Set<AbilityScore> = []
    
    @State private var showDeleteAlert = false
    
    private let classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard"]
    private let races = ["Dragonborn", "Dwarf", "Elf", "Gnome", "Half-Elf", "Half-Orc", "Halfling", "Human", "Tiefling"]
    
    var body: some View {
        Form {
            EditCharacterBasicSection(
                name: $name,
                characterClass: $characterClass,
                race: $race,
                level: $level,
                experiencePoints: $experiencePoints,
                classes: classes,
                races: races
            )
            
            EditCharacterAbilitySection(
                strength: $strength,
                dexterity: $dexterity,
                constitution: $constitution,
                intelligence: $intelligence,
                wisdom: $wisdom,
                charisma: $charisma
            )
            
            EditCharacterCombatSection(
                armorClass: $armorClass,
                hitPoints: $hitPoints,
                maxHitPoints: $maxHitPoints,
                speed: $speed,
                proficiencyBonus: $proficiencyBonus
            )
            
            EditCharacterSkillsSection(selectedSkills: $selectedSkills)
            
            EditCharacterSavingThrowsSection(selectedSavingThrows: $selectedSavingThrows)
            
            Section("Equipment") {
                TextField("Weapon", text: $equippedWeapon)
                TextField("Armor", text: $equippedArmor)
            }
            
            Section("Backstory") {
                TextEditor(text: $backstory)
                    .frame(height: 100)
            }
            
            Section("Notes") {
                TextEditor(text: $notes)
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
                Button("Save") {
                    saveCharacter()
                }
                .disabled(name.isEmpty)
            }
        }
        .alert("Delete Character?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                manager.deleteCharacter(character)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {
            loadCharacterData()
        }
    }
    
    private func loadCharacterData() {
        name = character.name
        characterClass = character.characterClass
        race = character.race
        level = character.level
        experiencePoints = character.experiencePoints
        
        strength = character.strength
        dexterity = character.dexterity
        constitution = character.constitution
        intelligence = character.intelligence
        wisdom = character.wisdom
        charisma = character.charisma
        
        armorClass = character.armorClass
        hitPoints = character.hitPoints
        maxHitPoints = character.maxHitPoints
        speed = character.speed
        proficiencyBonus = character.proficiencyBonus
        
        equippedWeapon = character.equippedWeapon
        equippedArmor = character.equippedArmor
        notes = character.notes
        backstory = character.backstory
        
        selectedSkills = Set(character.proficientSkills)
        selectedSavingThrows = Set(character.proficientSavingThrows)
    }
    
    private func saveCharacter() {
        var updated = character
        updated.name = name
        updated.characterClass = characterClass
        updated.race = race
        updated.level = level
        updated.experiencePoints = experiencePoints
        
        updated.strength = strength
        updated.dexterity = dexterity
        updated.constitution = constitution
        updated.intelligence = intelligence
        updated.wisdom = wisdom
        updated.charisma = charisma
        
        updated.armorClass = armorClass
        updated.hitPoints = hitPoints
        updated.maxHitPoints = maxHitPoints
        updated.speed = speed
        updated.proficiencyBonus = proficiencyBonus
        
        updated.equippedWeapon = equippedWeapon
        updated.equippedArmor = equippedArmor
        updated.notes = notes
        updated.backstory = backstory
        
        updated.proficientSkills = Array(selectedSkills)
        updated.proficientSavingThrows = Array(selectedSavingThrows)
        
        manager.updateCharacter(updated)
        dismiss()
    }
}

#Preview {
    NavigationView {
        EditCharacterView(character: PlayerCharacter(name: "Test"))
    }
}
