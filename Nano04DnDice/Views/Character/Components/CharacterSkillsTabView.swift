
import SwiftUI

struct CharacterSkillsTabView: View {
    let character: PlayerCharacter
    
    var body: some View {
        List {
            ForEach(Skill.allCases, id: \.self) { skill in
                SkillRow(skill: skill, character: character)
            }
        }
        .listStyle(.plain)
    }
}

struct SkillRow: View {
    let skill: Skill
    let character: PlayerCharacter
    
    var isProficient: Bool {
        character.proficientSkills.contains(skill)
    }
    
    var modifier: Int {
        character.skillModifier(for: skill)
    }
    
    var body: some View {
        HStack {
            Image(systemName: isProficient ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isProficient ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(skill.rawValue)
                    .font(.body)
                Text(skill.abilityScore.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatModifier(modifier))
                .font(.headline)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 4)
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}
