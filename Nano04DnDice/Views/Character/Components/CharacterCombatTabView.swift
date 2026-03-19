import SwiftUI
import SwiftData

struct CharacterCombatTabView: View {
    let character: PlayerCharacter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // HP Section
                VStack(spacing: 12) {
                    HStack {
                        Text("Hit Points")
                            .font(.headline)
                        Spacer()
                        Text("\(character.hitPoints) / \(character.maxHitPoints)")
                            .font(.headline)
                    }
                    
                    ProgressView(value: character.healthPercentage)
                        .tint(healthColor)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                
                // Equipment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Equipment")
                        .font(.headline)
                    
                    EquipmentRow(icon: "shield.fill", title: "Armor", name: character.equippedArmor)
                    EquipmentRow(icon: "sword.fill", title: "Weapon", name: character.equippedWeapon)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            }
            .padding()
        }
    }
    
    private var healthColor: Color {
        if character.healthPercentage > 0.6 { return .green }
        if character.healthPercentage > 0.3 { return .orange }
        return .red
    }
}

struct EquipmentRow: View {
    let icon: String
    let title: String
    let name: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(name.isEmpty ? "None" : name)
                    .font(.body)
            }
        }
    }
}