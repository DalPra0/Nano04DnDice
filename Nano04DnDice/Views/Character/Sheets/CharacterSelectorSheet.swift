
import SwiftUI

struct CharacterSelectorSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = CharacterManager.shared
    @State private var showingAddCharacter = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(manager.characters) { character in
                    Button(action: {
                        manager.setActiveCharacter(character)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(character.name)
                                    .font(.headline)
                                Text("\(character.race) \(character.characterClass) • Lvl \(character.level)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if manager.activeCharacterId == character.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteCharacters)
            }
            .navigationTitle("Select Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCharacter = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCharacter) {
                AddCharacterView()
            }
        }
    }
    
    private func deleteCharacters(at offsets: IndexSet) {
        for index in offsets {
            manager.deleteCharacter(manager.characters[index])
        }
    }
}

struct PDFShareSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingActivityView = false
    
    var pdfURL: URL? {
        if let url = Bundle.main.url(forResource: "5E_CharacterSheet_Fillable", withExtension: "pdf", subdirectory: "Resources/CharacterSheetModel") {
            return url
        }
        return Bundle.main.url(forResource: "5E_CharacterSheet_Fillable", withExtension: "pdf")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("D&D 5E Character Sheet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Official fillable PDF character sheet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if pdfURL != nil {
                    Button(action: {
                        showingActivityView = true
                    }) {
                        Label("Download PDF", systemImage: "arrow.down.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else {
                    Text("PDF file not found")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
            .navigationTitle("Character Sheet PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingActivityView) {
                if let url = pdfURL {
                    ActivityViewController(activityItems: [url])
                }
            }
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
