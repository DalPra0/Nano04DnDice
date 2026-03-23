
import SwiftUI
import SwiftData

struct CharacterSheetView: View {
    @EnvironmentObject private var subManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var characters: [PlayerCharacter]
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    @State private var showingAddCharacter = false
    @State private var showingCharacterSelector = false
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?
    
    private var accentColor: Color {
        themeManager.currentTheme.accentColor.color
    }
    
    private var activeCharacter: PlayerCharacter? {
        characters.first { $0.isActive } ?? characters.first
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.black.opacity(0.8), Color.black],
                center: .center,
                startRadius: 100,
                endRadius: 500
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                customHeader
                
                if let character = activeCharacter {
                    VStack(spacing: 0) {
                        // Character Identity Summary
                        CharacterIdentityHeader(character: character, accentColor: accentColor)
                        
                        // Custom Tab Selector
                        HStack(spacing: 0) {
                            TabButton(title: "STATS", icon: "bolt.fill", isSelected: selectedTab == 0, accentColor: accentColor) { selectedTab = 0 }
                            TabButton(title: "SKILLS", icon: "star.fill", isSelected: selectedTab == 1, accentColor: accentColor) { selectedTab = 1 }
                            TabButton(title: "COMBAT", icon: "shield.fill", isSelected: selectedTab == 2, accentColor: accentColor) { selectedTab = 2 }
                            TabButton(title: "SPELLS", icon: "sparkles", isSelected: selectedTab == 3, accentColor: accentColor) { selectedTab = 3 }
                            TabButton(title: "INFO", icon: "info.circle.fill", isSelected: selectedTab == 4, accentColor: accentColor) { selectedTab = 4 }
                        }
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.03))
                        
                        TabView(selection: $selectedTab) {
                            CharacterStatsTabView(character: character)
                                .tag(0)
                            
                            CharacterSkillsTabView(character: character)
                                .tag(1)
                            
                            CharacterCombatTabView(character: character)
                                .tag(2)
                            
                            CharacterSpellsTabView(character: character)
                                .tag(3)
                            
                            CharacterInfoTabView(character: character)
                                .tag(4)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                } else {
                    Spacer()
                    EmptyCharacterView(onCreateCharacter: { 
                        showingAddCharacter = true
                    })
                    .padding(40)
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCharacterSelector) {
            CharacterSelectorSheet()
        }
        .sheet(isPresented: $showingAddCharacter) {
            AddCharacterView()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private var customHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("CHARACTER SHEET")
                        .font(.custom("PlayfairDisplay-Black", size: 16))
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    if let character = activeCharacter {
                        Text(character.name.uppercased())
                            .font(.custom("PlayfairDisplay-Bold", size: 10))
                            .foregroundColor(accentColor.opacity(0.7))
                            .tracking(1)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    if let character = activeCharacter {
                        Button(action: {
                            pdfURL = PDFManager.shared.generateCharacterPDF(character: character)
                            if pdfURL != nil { showingShareSheet = true }
                        }) {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.system(size: 18))
                                .foregroundColor(accentColor)
                                .frame(width: 44, height: 44)
                        }
                    }
                    
                    Button(action: { showingCharacterSelector = true }) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(accentColor)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            LinearGradient(
                colors: [Color.clear, accentColor.opacity(0.5), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
        .background(Color.black.opacity(0.8))
    }
}

struct CharacterIdentityHeader: View {
    let character: PlayerCharacter
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Character Level Shield
            ZStack {
                Circle()
                    .stroke(accentColor.opacity(0.5), lineWidth: 2)
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 0) {
                    Text("LVL")
                        .font(.custom("PlayfairDisplay-Bold", size: 8))
                    Text("\(character.level)")
                        .font(.custom("PlayfairDisplay-Black", size: 18))
                }
                .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.custom("PlayfairDisplay-Black", size: 24))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(character.race)
                    Text("•")
                    Text(character.characterClass)
                }
                .font(.custom("PlayfairDisplay-Bold", size: 14))
                .foregroundColor(accentColor.opacity(0.8))
            }
            
            Spacer()
            
            // Edit Button
            NavigationLink(destination: EditCharacterView(character: character)) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(accentColor.opacity(0.3))
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.02))
    }
}
