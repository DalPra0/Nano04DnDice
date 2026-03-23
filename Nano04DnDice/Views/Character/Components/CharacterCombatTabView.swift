import SwiftUI
import SwiftData

struct CharacterCombatTabView: View {
    @Bindable var character: PlayerCharacter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // HP & Resting Section
                VStack(spacing: 16) {
                    HStack {
                        Text("Hit Points")
                            .font(.headline)
                        Spacer()
                        Text("\(character.hitPoints) / \(character.maxHitPoints)")
                            .font(.headline)
                    }
                    
                    ProgressView(value: character.healthPercentage)
                        .tint(healthColor)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            // Short Rest
                            character.shortRest(healing: Int.random(in: 1...8) + character.conModifier) // Simplified hit die
                        }) {
                            Text("Short Rest")
                                .font(.subheadline).bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            // Long Rest
                            character.longRest()
                        }) {
                            Text("Long Rest")
                                .font(.subheadline).bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                
                // Attacks
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Attacks & Spellcasting")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            if character.attacks == nil { character.attacks = [] }
                            character.attacks?.append(CharacterAttack(name: "New Attack", attackBonus: character.proficiencyBonus + character.strModifier, damageDice: "1d8", damageBonus: character.strModifier, damageType: "Slashing"))
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    
                    if (character.attacks ?? []).isEmpty {
                        Text("No attacks configured.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(character.attacks ?? []) { attack in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(attack.name)
                                        .font(.headline)
                                    Text("\(attack.damageDice) + \(attack.damageBonus) \(attack.damageType)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    // Trigger roll in main view
                                    NotificationCenter.default.post(name: NSNotification.Name("RollAttack"), object: nil, userInfo: ["attackBonus": attack.attackBonus, "damageDice": attack.damageDice])
                                    dismiss()
                                }) {
                                    Text("+\(attack.attackBonus) TO HIT")
                                        .font(.subheadline).bold()
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.2))
                                        .foregroundColor(.accentColor)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                
                // Equipment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Armor & Defense")
                        .font(.headline)
                    
                    EquipmentRow(icon: "shield.fill", title: "Armor", name: character.equippedArmor)
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
