
import SwiftUI
import SwiftData
import RevenueCatUI

struct CharacterSheetView: View {
    @EnvironmentObject private var subManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query private var characters: [PlayerCharacter]
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    @State private var showingAddCharacter = false
    @State private var showingCharacterSelector = false
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?
    
    private var activeCharacter: PlayerCharacter? {
        characters.first { $0.isActive } ?? characters.first
    }
    
    var body: some View {
        NavigationView {
            if let character = activeCharacter {
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
                            Button(action: { 
                                if subManager.isPro {
                                    pdfURL = PDFManager.shared.generateCharacterPDF(character: character)
                                    if pdfURL != nil {
                                        showingShareSheet = true
                                    }
                                } else {
                                    subManager.showPaywall = true
                                }
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "arrow.down.doc")
                                    if !subManager.isPro {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(.yellow)
                                            .offset(x: 4, y: -4)
                                    }
                                }
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
                    if let url = pdfURL {
                        ShareSheet(activityItems: [url])
                    }
                }
            } else {
                EmptyCharacterView(onCreateCharacter: { 
                    if subManager.canAddItem(currentCount: characters.count) {
                        showingAddCharacter = true
                    } else {
                        subManager.showPaywall = true
                    }
                })
            }
        }
        .sheet(isPresented: $showingAddCharacter) {
            AddCharacterView()
        }
        .sheet(isPresented: $subManager.showPaywall) {
            PaywallView(displayCloseButton: true)
        }
        .enableInjection()
    }
}

#Preview {
    CharacterSheetView()
}
