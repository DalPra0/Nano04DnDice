import SwiftUI
import Foundation

struct NPCRowView: View {
    let npc: NPC
    
    var body: some View {
        HStack(spacing: 12) {
            // Health Circle
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: npc.healthPercentage)
                    .stroke(npc.healthColor, lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(npc.hitPoints)")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(npc.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if !npc.characterClass.isEmpty {
                        Text(npc.characterClass)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !npc.race.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(npc.race)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if npc.level > 0 {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("Lvl \(npc.level)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                    Text("\(npc.hitPoints)/\(npc.maxHitPoints)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "shield.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("AC \(npc.armorClass)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
