import SwiftUI

struct CharacterInfoTabView: View {
    @Bindable var character: PlayerCharacter
    
    var body: some View {
        Form {
            Section("Details") {
                InfoRow(title: "Race", value: character.race)
                InfoRow(title: "Class", value: character.characterClass)
                InfoRow(title: "Level", value: "\(character.level)")
                InfoRow(title: "XP", value: "\(character.experiencePoints)")
            }
            
            Section("Wealth") {
                HStack {
                    CurrencyView(value: Binding(get: { character.currency?.copper ?? 0 }, set: { if character.currency == nil { character.currency = Currency() }; character.currency?.copper = $0 }), label: "CP", color: .orange)
                    CurrencyView(value: Binding(get: { character.currency?.silver ?? 0 }, set: { if character.currency == nil { character.currency = Currency() }; character.currency?.silver = $0 }), label: "SP", color: .gray)
                    CurrencyView(value: Binding(get: { character.currency?.gold ?? 0 }, set: { if character.currency == nil { character.currency = Currency() }; character.currency?.gold = $0 }), label: "GP", color: .yellow)
                    CurrencyView(value: Binding(get: { character.currency?.platinum ?? 0 }, set: { if character.currency == nil { character.currency = Currency() }; character.currency?.platinum = $0 }), label: "PP", color: .cyan)
                }
            }
            
            Section {
                ForEach(character.traits ?? []) { trait in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trait.name).font(.headline)
                        Text(trait.source).font(.caption).foregroundColor(.secondary)
                        Text(trait.descriptionText).font(.body)
                    }
                    .padding(.vertical, 4)
                }
                
                Button(action: {
                    if character.traits == nil { character.traits = [] }
                    character.traits?.append(CharacterTrait(name: "New Trait", descriptionText: "Trait description..."))
                }) {
                    Label("Add Trait", systemImage: "plus")
                }
            } header: {
                Text("Features & Traits")
            }
            
            if !character.backstory.isEmpty {
                Section("Backstory") {
                    Text(character.backstory)
                        .font(.body)
                }
            }
            
            if !character.notes.isEmpty {
                Section("Notes") {
                    Text(character.notes)
                        .font(.body)
                }
            }
        }
    }
}

struct CurrencyView: View {
    @Binding var value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(color)
            TextField("0", value: $value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}
