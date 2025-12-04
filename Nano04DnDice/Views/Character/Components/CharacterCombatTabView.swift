
import SwiftUI

struct CharacterCombatTabView: View {
    let character: PlayerCharacter
    @StateObject private var manager = CharacterManager.shared
    @State private var damageAmount = 0
    @State private var healAmount = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    CombatStatCard(title: "AC", value: "\(character.armorClass)", icon: "shield.fill", color: .blue)
                    CombatStatCard(title: "Initiative", value: formatModifier(character.dexModifier), icon: "bolt.fill", color: .yellow)
                    CombatStatCard(title: "Speed", value: "\(character.speed)", icon: "figure.run", color: .green)
                }
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    Text("Hit Points")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Stepper("Damage: \(damageAmount)", value: $damageAmount, in: 0...100)
                            
                            Button(action: {
                                var updated = character
                                updated.hitPoints = max(0, character.hitPoints - damageAmount)
                                manager.updateCharacter(updated)
                                damageAmount = 0
                            }) {
                                Label("Take Damage", systemImage: "heart.slash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .disabled(damageAmount == 0)
                        }
                        
                        VStack {
                            Stepper("Heal: \(healAmount)", value: $healAmount, in: 0...100)
                            
                            Button(action: {
                                var updated = character
                                updated.hitPoints = min(character.maxHitPoints, character.hitPoints + healAmount)
                                manager.updateCharacter(updated)
                                healAmount = 0
                            }) {
                                Label("Heal", systemImage: "heart.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)
                            .disabled(healAmount == 0)
                        }
                    }
                    
                    Button(action: {
                        var updated = character
                        updated.hitPoints = character.maxHitPoints
                        manager.updateCharacter(updated)
                    }) {
                        Label("Full Heal", systemImage: "heart.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Equipment")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if !character.equippedWeapon.isEmpty {
                        EquipmentRow(icon: "sword.fill", title: "Weapon", value: character.equippedWeapon)
                    }
                    
                    if !character.equippedArmor.isEmpty {
                        EquipmentRow(icon: "shield.fill", title: "Armor", value: character.equippedArmor)
                    }
                    
                    ForEach(character.equippedItems, id: \.self) { item in
                        EquipmentRow(icon: "bag.fill", title: "Item", value: item)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}

struct CombatStatCard: View {
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
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EquipmentRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
