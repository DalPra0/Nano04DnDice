import SwiftUI
import Foundation

struct EditNPCView: View {
    @StateObject private var manager = CampaignManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let campaignId: UUID
    let npc: NPC
    
    @State private var name = ""
    @State private var race = ""
    @State private var characterClass = ""
    @State private var level = 1
    @State private var maxHitPoints = 10
    @State private var hitPoints = 10
    @State private var armorClass = 10
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("NPC Name", text: $name)
                    TextField("Race", text: $race)
                    TextField("Class", text: $characterClass)
                }
                
                Section(header: Text("Stats")) {
                    Stepper("Level: \(level)", value: $level, in: 1...20)
                    
                    Stepper("Max HP: \(maxHitPoints)", value: $maxHitPoints, in: 1...999)
                        .onChange(of: maxHitPoints) {
                            if hitPoints > maxHitPoints {
                                hitPoints = maxHitPoints
                            }
                        }
                    
                    Stepper("Current HP: \(hitPoints)", value: $hitPoints, in: 0...maxHitPoints)
                    
                    Stepper("AC: \(armorClass)", value: $armorClass, in: 1...30)
                }
                
                Section(header: Text("Quick Actions")) {
                    HStack {
                        Button(action: {
                            hitPoints = max(0, hitPoints - 5)
                        }) {
                            Label("Damage -5", systemImage: "heart.slash.fill")
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            hitPoints = min(maxHitPoints, hitPoints + 5)
                        }) {
                            Label("Heal +5", systemImage: "heart.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Button(action: {
                        hitPoints = maxHitPoints
                    }) {
                        Label("Full Heal", systemImage: "bolt.heart.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit NPC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNPC()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = npc.name
                race = npc.race
                characterClass = npc.characterClass
                level = npc.level
                maxHitPoints = npc.maxHitPoints
                hitPoints = npc.hitPoints
                armorClass = npc.armorClass
                notes = npc.notes
            }
        }
    }
    
    private func saveNPC() {
        var updated = npc
        updated.name = name
        updated.race = race
        updated.characterClass = characterClass
        updated.level = level
        updated.maxHitPoints = maxHitPoints
        updated.hitPoints = hitPoints
        updated.armorClass = armorClass
        updated.notes = notes
        
        manager.updateNPC(updated)
        dismiss()
    }
}
