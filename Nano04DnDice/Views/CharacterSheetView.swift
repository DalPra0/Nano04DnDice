
import SwiftUI

struct CharacterSheetView: View {
    @StateObject private var manager = CharacterManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    @State private var showingAddCharacter = false
    @State private var showingCharacterSelector = false
    
    var body: some View {
        NavigationView {
            if let character = manager.activeCharacter {
                VStack(spacing: 0) {
                    // Character Header
                    CharacterHeaderView(character: character)
                        .padding()
                        .background(Color(.systemGray6))
                    
                    // Tab Selector
                    Picker("View", selection: $selectedTab) {
                        Text("Stats").tag(0)
                        Text("Skills").tag(1)
                        Text("Combat").tag(2)
                        Text("Info").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        AbilityScoresView(character: character)
                            .tag(0)
                        
                        SkillsView(character: character)
                            .tag(1)
                        
                        CombatView(character: character)
                            .tag(2)
                        
                        CharacterInfoView(character: character)
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
                        NavigationLink(destination: EditCharacterView(character: character)) {
                            Text("Edit")
                        }
                    }
                }
                .sheet(isPresented: $showingCharacterSelector) {
                    CharacterSelectorView()
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

// MARK: - Character Header

struct CharacterHeaderView: View {
    let character: PlayerCharacter
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Text(character.race)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(character.characterClass)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("Level \(character.level)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Text("\(character.level)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                    
                    Text("LVL")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Health Bar
            VStack(spacing: 4) {
                HStack {
                    Label("\(character.hitPoints)/\(character.maxHitPoints) HP", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    Spacer()
                    Text("\(Int(character.healthPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                        
                        Rectangle()
                            .fill(
                                character.healthPercentage > 0.6 ? Color.green :
                                character.healthPercentage > 0.3 ? Color.orange : Color.red
                            )
                            .frame(width: geometry.size.width * character.healthPercentage)
                    }
                    .frame(height: 8)
                    .cornerRadius(4)
                }
                .frame(height: 8)
            }
        }
    }
}

// MARK: - Empty Character View

struct EmptyCharacterView: View {
    let onCreateCharacter: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Character")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a character to start tracking stats and skills")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onCreateCharacter) {
                Label("Create Character", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
}

// MARK: - Ability Scores View

struct AbilityScoresView: View {
    let character: PlayerCharacter
    @StateObject private var manager = CharacterManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Quick Stats
                HStack(spacing: 12) {
                    QuickStatCard(title: "Prof Bonus", value: "+\(character.proficiencyBonus)", icon: "plus.circle.fill", color: .blue)
                    QuickStatCard(title: "Initiative", value: formatModifier(character.dexModifier), icon: "bolt.fill", color: .yellow)
                    QuickStatCard(title: "Speed", value: "\(character.speed) ft", icon: "figure.walk", color: .green)
                }
                .padding(.horizontal)
                
                // Ability Scores
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(AbilityScore.allCases, id: \.self) { ability in
                        AbilityScoreCard(ability: ability, character: character)
                    }
                }
                .padding(.horizontal)
                
                // Saving Throws
                VStack(alignment: .leading, spacing: 12) {
                    Text("Saving Throws")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(AbilityScore.allCases, id: \.self) { ability in
                        SavingThrowRow(ability: ability, character: character)
                    }
                }
                .padding(.vertical)
            }
            .padding(.vertical)
        }
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AbilityScoreCard: View {
    let ability: AbilityScore
    let character: PlayerCharacter
    
    var score: Int {
        switch ability {
        case .strength: return character.strength
        case .dexterity: return character.dexterity
        case .constitution: return character.constitution
        case .intelligence: return character.intelligence
        case .wisdom: return character.wisdom
        case .charisma: return character.charisma
        }
    }
    
    var modifier: Int {
        character.modifier(for: score)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: ability.icon)
                    .foregroundColor(.accentColor)
                Text(ability.rawValue)
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Modifier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatModifier(modifier))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}

struct SavingThrowRow: View {
    let ability: AbilityScore
    let character: PlayerCharacter
    
    var isProficient: Bool {
        character.proficientSavingThrows.contains(ability)
    }
    
    var modifier: Int {
        character.savingThrowModifier(for: ability)
    }
    
    var body: some View {
        HStack {
            Image(systemName: isProficient ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isProficient ? .green : .gray)
            
            Text(ability.fullName)
                .font(.body)
            
            Spacer()
            
            Text(formatModifier(modifier))
                .font(.headline)
                .foregroundColor(.accentColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}

// MARK: - Skills View

struct SkillsView: View {
    let character: PlayerCharacter
    
    var body: some View {
        List {
            ForEach(Skill.allCases, id: \.self) { skill in
                SkillRow(skill: skill, character: character)
            }
        }
        .listStyle(.plain)
    }
}

struct SkillRow: View {
    let skill: Skill
    let character: PlayerCharacter
    
    var isProficient: Bool {
        character.proficientSkills.contains(skill)
    }
    
    var modifier: Int {
        character.skillModifier(for: skill)
    }
    
    var body: some View {
        HStack {
            Image(systemName: isProficient ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isProficient ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(skill.rawValue)
                    .font(.body)
                Text(skill.abilityScore.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatModifier(modifier))
                .font(.headline)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 4)
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}

// MARK: - Combat View

struct CombatView: View {
    let character: PlayerCharacter
    @StateObject private var manager = CharacterManager.shared
    @State private var damageAmount = 0
    @State private var healAmount = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Combat Stats
                HStack(spacing: 12) {
                    CombatStatCard(title: "AC", value: "\(character.armorClass)", icon: "shield.fill", color: .blue)
                    CombatStatCard(title: "Initiative", value: formatModifier(character.dexModifier), icon: "bolt.fill", color: .yellow)
                    CombatStatCard(title: "Speed", value: "\(character.speed)", icon: "figure.run", color: .green)
                }
                .padding(.horizontal)
                
                // HP Management
                VStack(spacing: 16) {
                    Text("Hit Points")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Stepper("Damage: \(damageAmount)", value: $damageAmount, in: 0...100)
                            
                            Button(action: {
                                var updated = character
                                updated.hitPoints = max(0, character.hitPoints - damageAmount)
                                manager.updateCharacter(updated)
                                damageAmount = 0
                            }) {
                                Label("Take Damage", systemImage: "heart.slash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .disabled(damageAmount == 0)
                        }
                        
                        VStack {
                            Stepper("Heal: \(healAmount)", value: $healAmount, in: 0...100)
                            
                            Button(action: {
                                var updated = character
                                updated.hitPoints = min(character.maxHitPoints, character.hitPoints + healAmount)
                                manager.updateCharacter(updated)
                                healAmount = 0
                            }) {
                                Label("Heal", systemImage: "heart.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)
                            .disabled(healAmount == 0)
                        }
                    }
                    
                    Button(action: {
                        var updated = character
                        updated.hitPoints = character.maxHitPoints
                        manager.updateCharacter(updated)
                    }) {
                        Label("Full Heal", systemImage: "heart.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Equipment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Equipment")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if !character.equippedWeapon.isEmpty {
                        EquipmentRow(icon: "sword.fill", title: "Weapon", value: character.equippedWeapon)
                    }
                    
                    if !character.equippedArmor.isEmpty {
                        EquipmentRow(icon: "shield.fill", title: "Armor", value: character.equippedArmor)
                    }
                    
                    ForEach(character.equippedItems, id: \.self) { item in
                        EquipmentRow(icon: "bag.fill", title: "Item", value: item)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}

struct CombatStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EquipmentRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Character Info View

struct CharacterInfoView: View {
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

// MARK: - Character Selector

struct CharacterSelectorView: View {
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

#Preview {
    CharacterSheetView()
}
