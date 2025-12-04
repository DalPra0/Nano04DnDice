
import SwiftUI

struct CharacterInfoTabView: View {
    let character: PlayerCharacter
    
    var body: some View {
        Form {
            Section("Details") {
                InfoRow(title: "Race", value: character.race)
                InfoRow(title: "Class", value: character.characterClass)
                InfoRow(title: "Level", value: "\(character.level)")
                InfoRow(title: "XP", value: "\(character.experiencePoints)")
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
