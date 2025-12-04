
import SwiftUI

// MARK: - Add Character

struct AddCharacterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CharacterManager.shared
    
    @State private var name = ""
    @State private var characterClass = "Fighter"
    @State private var race = "Human"
    @State private var level = 1
    
    @State private var strength = 10
    @State private var dexterity = 10
    @State private var constitution = 10
    @State private var intelligence = 10
    @State private var wisdom = 10
    @State private var charisma = 10
    
    private let classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard"]
    private let races = ["Dragonborn", "Dwarf", "Elf", "Gnome", "Half-Elf", "Half-Orc", "Halfling", "Human", "Tiefling"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Character Name", text: $name)
                    
                    Picker("Class", selection: $characterClass) {
                        ForEach(classes, id: \.self) { classType in
                            Text(classType).tag(classType)
                        }
                    }
                    
                    Picker("Race", selection: $race) {
                        ForEach(races, id: \.self) { raceType in
                            Text(raceType).tag(raceType)
                        }
                    }
                    
                    Stepper("Level: \(level)", value: $level, in: 1...20)
                }
                
                Section("Ability Scores") {
                    HStack {
                        Text("Roll for Stats")
                        Spacer()
                        Button(action: rollStats) {
                            Label("Roll 4d6", systemImage: "dice.fill")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    AbilityScoreRow(title: "Strength", icon: "figure.strengthtraining.traditional", value: $strength)
                    AbilityScoreRow(title: "Dexterity", icon: "figure.run", value: $dexterity)
                    AbilityScoreRow(title: "Constitution", icon: "heart.fill", value: $constitution)
                    AbilityScoreRow(title: "Intelligence", icon: "brain.head.profile", value: $intelligence)
                    AbilityScoreRow(title: "Wisdom", icon: "eye.fill", value: $wisdom)
                    AbilityScoreRow(title: "Charisma", icon: "sparkles", value: $charisma)
                }
            }
            .navigationTitle("New Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createCharacter()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func rollStats() {
        strength = rollAbilityScore()
        dexterity = rollAbilityScore()
        constitution = rollAbilityScore()
        intelligence = rollAbilityScore()
        wisdom = rollAbilityScore()
        charisma = rollAbilityScore()
    }
    
    private func rollAbilityScore() -> Int {
        // Roll 4d6, drop lowest
        let rolls = (1...4).map { _ in Int.random(in: 1...6) }
        let sorted = rolls.sorted()
        return sorted.dropFirst().reduce(0, +)
    }
    
    private func createCharacter() {
        let character = PlayerCharacter(
            name: name,
            characterClass: characterClass,
            race: race,
            level: level,
            strength: strength,
            dexterity: dexterity,
            constitution: constitution,
            intelligence: intelligence,
            wisdom: wisdom,
            charisma: charisma,
            maxHitPoints: calculateHP(),
            hitPoints: calculateHP()
        )
        manager.addCharacter(character)
        dismiss()
    }
    
    private func calculateHP() -> Int {
        let hitDice: Int
        switch characterClass {
        case "Barbarian": hitDice = 12
        case "Fighter", "Paladin", "Ranger": hitDice = 10
        case "Bard", "Cleric", "Druid", "Monk", "Rogue", "Warlock": hitDice = 8
        default: hitDice = 6
        }
        
        let conModifier = (constitution - 10) / 2
        return hitDice + conModifier
    }
}

struct AbilityScoreRow: View {
    let title: String
    let icon: String
    @Binding var value: Int
    
    var modifier: Int {
        (value - 10) / 2
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(title)
            
            Spacer()
            
            Text(formatModifier(modifier))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            Stepper("\(value)", value: $value, in: 3...20)
                .labelsHidden()
        }
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}

// MARK: - Edit Character

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
            Section("Basic Info") {
                TextField("Character Name", text: $name)
                
                Picker("Class", selection: $characterClass) {
                    ForEach(classes, id: \.self) { classType in
                        Text(classType).tag(classType)
                    }
                }
                
                Picker("Race", selection: $race) {
                    ForEach(races, id: \.self) { raceType in
                        Text(raceType).tag(raceType)
                    }
                }
                
                Stepper("Level: \(level)", value: $level, in: 1...20)
                Stepper("XP: \(experiencePoints)", value: $experiencePoints, in: 0...355000, step: 100)
            }
            
            Section("Ability Scores") {
                AbilityScoreRow(title: "Strength", icon: "figure.strengthtraining.traditional", value: $strength)
                AbilityScoreRow(title: "Dexterity", icon: "figure.run", value: $dexterity)
                AbilityScoreRow(title: "Constitution", icon: "heart.fill", value: $constitution)
                AbilityScoreRow(title: "Intelligence", icon: "brain.head.profile", value: $intelligence)
                AbilityScoreRow(title: "Wisdom", icon: "eye.fill", value: $wisdom)
                AbilityScoreRow(title: "Charisma", icon: "sparkles", value: $charisma)
            }
            
            Section("Combat Stats") {
                Stepper("Armor Class: \(armorClass)", value: $armorClass, in: 1...30)
                Stepper("Hit Points: \(hitPoints)", value: $hitPoints, in: 0...999)
                Stepper("Max HP: \(maxHitPoints)", value: $maxHitPoints, in: 1...999)
                Stepper("Speed: \(speed) ft", value: $speed, in: 0...120, step: 5)
                Stepper("Proficiency: +\(proficiencyBonus)", value: $proficiencyBonus, in: 2...6)
            }
            
            Section("Proficient Skills") {
                ForEach(Skill.allCases, id: \.self) { skill in
                    Toggle(isOn: Binding(
                        get: { selectedSkills.contains(skill) },
                        set: { isOn in
                            if isOn {
                                selectedSkills.insert(skill)
                            } else {
                                selectedSkills.remove(skill)
                            }
                        }
                    )) {
                        HStack {
                            Text(skill.rawValue)
                            Text("(\(skill.abilityScore.rawValue))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section("Proficient Saving Throws") {
                ForEach(AbilityScore.allCases, id: \.self) { ability in
                    Toggle(ability.fullName, isOn: Binding(
                        get: { selectedSavingThrows.contains(ability) },
                        set: { isOn in
                            if isOn {
                                selectedSavingThrows.insert(ability)
                            } else {
                                selectedSavingThrows.remove(ability)
                            }
                        }
                    ))
                }
            }
            
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
    AddCharacterView()
}
