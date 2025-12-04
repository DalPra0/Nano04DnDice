
import SwiftUI

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AbilityScoreCard: View {
    let ability: AbilityScore
    let character: PlayerCharacter
    
    var score: Int {
        switch ability {
        case .strength: return character.strength
        case .dexterity: return character.dexterity
        case .constitution: return character.constitution
        case .intelligence: return character.intelligence
        case .wisdom: return character.wisdom
        case .charisma: return character.charisma
        }
    }
    
    var modifier: Int {
        character.modifier(for: score)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: ability.icon)
                    .foregroundColor(.accentColor)
                Text(ability.rawValue)
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Modifier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatModifier(modifier))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}

struct SavingThrowRow: View {
    let ability: AbilityScore
    let character: PlayerCharacter
    
    var isProficient: Bool {
        character.proficientSavingThrows.contains(ability)
    }
    
    var modifier: Int {
        character.savingThrowModifier(for: ability)
    }
    
    var body: some View {
        HStack {
            Image(systemName: isProficient ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isProficient ? .green : .gray)
            
            Text(ability.fullName)
                .font(.body)
            
            Spacer()
            
            Text(formatModifier(modifier))
                .font(.headline)
                .foregroundColor(.accentColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}
