
import SwiftUI

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
            hitPoints: calculateHP(),
            maxHitPoints: calculateHP()
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

#Preview {
    AddCharacterView()
}
