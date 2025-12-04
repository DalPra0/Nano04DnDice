
import SwiftUI

struct CharacterSheetView: View {
    @StateObject private var manager = CharacterManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    @State private var showingAddCharacter = false
    @State private var showingCharacterSelector = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            if let character = manager.activeCharacter {
                VStack(spacing: 0) {
                    CharacterHeaderView(character: character)
                        .padding()
                        .background(Color(.systemGray6))
                    
                    Picker("View", selection: $selectedTab) {
                        Text("Stats").tag(0)
                        Text("Skills").tag(1)
                        Text("Combat").tag(2)
                        Text("Info").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        CharacterStatsTabView(character: character)
                            .tag(0)
                        
                        CharacterSkillsTabView(character: character)
                            .tag(1)
                        
                        CharacterCombatTabView(character: character)
                            .tag(2)
                        
                        CharacterInfoTabView(character: character)
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationTitle("Character Sheet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingCharacterSelector = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "person.crop.circle")
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            Button(action: { showingShareSheet = true }) {
                                Image(systemName: "arrow.down.doc")
                            }
                            
                            NavigationLink(destination: EditCharacterView(character: character)) {
                                Text("Edit")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingCharacterSelector) {
                    CharacterSelectorSheet()
                }
                .sheet(isPresented: $showingShareSheet) {
                    PDFShareSheet()
                }
            } else {
                EmptyCharacterView(onCreateCharacter: { showingAddCharacter = true })
            }
        }
        .sheet(isPresented: $showingAddCharacter) {
            AddCharacterView()
        }
    }
}

#Preview {
    CharacterSheetView()
}
