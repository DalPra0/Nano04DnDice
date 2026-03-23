import SwiftUI
import SwiftData

struct AddNPCView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let campaign: Campaign
    
    @State private var name = ""
    @State private var race = ""
    @State private var characterClass = ""
    @State private var level = 1
    @State private var maxHitPoints = 10
    @State private var hitPoints = 10
    @State private var armorClass = 10
    @State private var initiative = 0
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
                    Stepper("Current HP: \(hitPoints)", value: $hitPoints, in: 0...maxHitPoints)
                    Stepper("AC: \(armorClass)", value: $armorClass, in: 1...30)
                    Stepper("Initiative: \(initiative)", value: $initiative, in: -10...40)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New NPC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let npc = NPC(
                            name: name,
                            race: race,
                            characterClass: characterClass,
                            level: level,
                            armorClass: armorClass,
                            hitPoints: hitPoints,
                            maxHitPoints: maxHitPoints,
                            initiative: initiative,
                            notes: notes
                        )
                        npc.campaign = campaign
                        modelContext.insert(npc)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}