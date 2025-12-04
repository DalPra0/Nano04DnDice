
import SwiftUI

struct EditCharacterBasicSection: View {
    @Binding var name: String
    @Binding var characterClass: String
    @Binding var race: String
    @Binding var level: Int
    @Binding var experiencePoints: Int
    
    let classes: [String]
    let races: [String]
    
    var body: some View {
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
    }
}

struct EditCharacterAbilitySection: View {
    @Binding var strength: Int
    @Binding var dexterity: Int
    @Binding var constitution: Int
    @Binding var intelligence: Int
    @Binding var wisdom: Int
    @Binding var charisma: Int
    
    var body: some View {
        Section("Ability Scores") {
            AbilityScoreRow(title: "Strength", icon: "figure.strengthtraining.traditional", value: $strength)
            AbilityScoreRow(title: "Dexterity", icon: "figure.run", value: $dexterity)
            AbilityScoreRow(title: "Constitution", icon: "heart.fill", value: $constitution)
            AbilityScoreRow(title: "Intelligence", icon: "brain.head.profile", value: $intelligence)
            AbilityScoreRow(title: "Wisdom", icon: "eye.fill", value: $wisdom)
            AbilityScoreRow(title: "Charisma", icon: "sparkles", value: $charisma)
        }
    }
}

struct EditCharacterCombatSection: View {
    @Binding var armorClass: Int
    @Binding var hitPoints: Int
    @Binding var maxHitPoints: Int
    @Binding var speed: Int
    @Binding var proficiencyBonus: Int
    
    var body: some View {
        Section("Combat Stats") {
            Stepper("Armor Class: \(armorClass)", value: $armorClass, in: 1...30)
            Stepper("Hit Points: \(hitPoints)", value: $hitPoints, in: 0...999)
            Stepper("Max HP: \(maxHitPoints)", value: $maxHitPoints, in: 1...999)
            Stepper("Speed: \(speed) ft", value: $speed, in: 0...120, step: 5)
            Stepper("Proficiency: +\(proficiencyBonus)", value: $proficiencyBonus, in: 2...6)
        }
    }
}

struct EditCharacterSkillsSection: View {
    @Binding var selectedSkills: Set<Skill>
    
    var body: some View {
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
    }
}

struct EditCharacterSavingThrowsSection: View {
    @Binding var selectedSavingThrows: Set<AbilityScore>
    
    var body: some View {
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
    }
}
