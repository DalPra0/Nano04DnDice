import SwiftUI
import SwiftData

struct EditNPCView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var npc: NPC
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("NPC Name", text: $npc.name)
                    TextField("Race", text: $npc.race)
                    TextField("Class", text: $npc.characterClass)
                }
                
                Section(header: Text("Stats")) {
                    Stepper("Level: \(npc.level)", value: $npc.level, in: 1...20)
                    Stepper("Max HP: \(npc.maxHitPoints)", value: $npc.maxHitPoints, in: 1...999)
                    Stepper("Current HP: \(npc.hitPoints)", value: $npc.hitPoints, in: 0...npc.maxHitPoints)
                    Stepper("AC: \(npc.armorClass)", value: $npc.armorClass, in: 1...30)
                    Stepper("Initiative: \(npc.initiative ?? 0)", value: Binding(get: { npc.initiative ?? 0 }, set: { npc.initiative = $0 }), in: -10...40)
                }
                
                Section(header: Text("Quick Actions")) {
                    HStack {
                        Button(action: { npc.hitPoints = max(0, npc.hitPoints - 5) }) {
                            Label("Damage -5", systemImage: "heart.slash.fill").foregroundColor(.red)
                        }
                        Spacer()
                        Button(action: { npc.hitPoints = min(npc.maxHitPoints, npc.hitPoints + 5) }) {
                            Label("Heal +5", systemImage: "heart.fill").foregroundColor(.green)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Notes", text: $npc.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit NPC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}