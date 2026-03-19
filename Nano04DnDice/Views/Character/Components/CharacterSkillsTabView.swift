import SwiftUI
import SwiftData

struct CharacterSkillsTabView: View {
    let character: PlayerCharacter
    
    var body: some View {
        List {
            ForEach(Skill.allCases, id: \.self) { skill in
                HStack {
                    Image(systemName: isProficient(skill) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isProficient(skill) ? .blue : .secondary)
                    
                    VStack(alignment: .leading) {
                        Text(skill.rawValue)
                            .font(.body)
                        Text(skill.abilityScore.fullName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(formatModifier(calculateModifier(for: skill)))
                        .font(.body.monospacedDigit())
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
    }
    
    private func isProficient(_ skill: Skill) -> Bool {
        character.proficientSkillsStrings.contains(skill.rawValue)
    }
    
    private func calculateModifier(for skill: Skill) -> Int {
        let baseScore: Int
        switch skill.abilityScore {
        case .strength: baseScore = character.strength
        case .dexterity: baseScore = character.dexterity
        case .constitution: baseScore = character.constitution
        case .intelligence: baseScore = character.intelligence
        case .wisdom: baseScore = character.wisdom
        case .charisma: baseScore = character.charisma
        }
        
        let baseMod = (baseScore - 10) / 2
        let bonus = isProficient(skill) ? character.proficiencyBonus : 0
        return baseMod + bonus
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}