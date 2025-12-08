
import Foundation
import SwiftUI
import Combine

// MARK: - Character Model

struct PlayerCharacter: Identifiable, Codable {
    let id: UUID
    var name: String
    var characterClass: String
    var race: String
    var level: Int
    var experiencePoints: Int
    
    // Ability Scores (8-20 typical range)
    var strength: Int
    var dexterity: Int
    var constitution: Int
    var intelligence: Int
    var wisdom: Int
    var charisma: Int
    
    // Combat Stats
    var armorClass: Int
    var hitPoints: Int
    var maxHitPoints: Int
    var initiative: Int
    var speed: Int
    
    // Proficiencies
    var proficiencyBonus: Int
    var proficientSkills: [Skill]
    var proficientSavingThrows: [AbilityScore]
    
    // Equipment
    var equippedWeapon: String
    var equippedArmor: String
    var equippedItems: [String]
    
    // Notes
    var notes: String
    var backstory: String
    
    // MARK: - Cached Modifiers (Performance Optimization)
    // Cache computed modifiers to avoid recalculating on every scroll/redraw
    private var _cachedStrModifier: Int = 0
    private var _cachedDexModifier: Int = 0
    private var _cachedConModifier: Int = 0
    private var _cachedIntModifier: Int = 0
    private var _cachedWisModifier: Int = 0
    private var _cachedChaModifier: Int = 0
    
    // MARK: - Codable
    // Exclude cached properties from encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, name, characterClass, race, level, experiencePoints
        case strength, dexterity, constitution, intelligence, wisdom, charisma
        case armorClass, hitPoints, maxHitPoints, initiative, speed
        case proficiencyBonus, proficientSkills, proficientSavingThrows
        case equippedWeapon, equippedArmor, equippedItems
        case notes, backstory
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        characterClass: String = "Fighter",
        race: String = "Human",
        level: Int = 1,
        experiencePoints: Int = 0,
        strength: Int = 10,
        dexterity: Int = 10,
        constitution: Int = 10,
        intelligence: Int = 10,
        wisdom: Int = 10,
        charisma: Int = 10,
        armorClass: Int = 10,
        hitPoints: Int = 10,
        maxHitPoints: Int = 10,
        initiative: Int = 0,
        speed: Int = 30,
        proficiencyBonus: Int = 2,
        proficientSkills: [Skill] = [],
        proficientSavingThrows: [AbilityScore] = [],
        equippedWeapon: String = "",
        equippedArmor: String = "",
        equippedItems: [String] = [],
        notes: String = "",
        backstory: String = ""
    ) {
        self.id = id
        self.name = name
        self.characterClass = characterClass
        self.race = race
        self.level = level
        self.experiencePoints = experiencePoints
        self.strength = strength
        self.dexterity = dexterity
        self.constitution = constitution
        self.intelligence = intelligence
        self.wisdom = wisdom
        self.charisma = charisma
        self.armorClass = armorClass
        self.hitPoints = hitPoints
        self.maxHitPoints = maxHitPoints
        self.initiative = initiative
        self.speed = speed
        self.proficiencyBonus = proficiencyBonus
        self.proficientSkills = proficientSkills
        self.proficientSavingThrows = proficientSavingThrows
        self.equippedWeapon = equippedWeapon
        self.equippedArmor = equippedArmor
        self.equippedItems = equippedItems
        self.notes = notes
        self.backstory = backstory
        
        // Cache computed modifiers for performance
        self._cachedStrModifier = modifier(for: strength)
        self._cachedDexModifier = modifier(for: dexterity)
        self._cachedConModifier = modifier(for: constitution)
        self._cachedIntModifier = modifier(for: intelligence)
        self._cachedWisModifier = modifier(for: wisdom)
        self._cachedChaModifier = modifier(for: charisma)
    }
    
    // Calculated Modifiers (cached for performance)
    func modifier(for score: Int) -> Int {
        return (score - 10) / 2
    }
    
    var strModifier: Int { _cachedStrModifier }
    var dexModifier: Int { _cachedDexModifier }
    var conModifier: Int { _cachedConModifier }
    var intModifier: Int { _cachedIntModifier }
    var wisModifier: Int { _cachedWisModifier }
    var chaModifier: Int { _cachedChaModifier }
    
    func skillModifier(for skill: Skill) -> Int {
        let baseModifier = modifier(for: abilityScore(for: skill))
        let proficiency = proficientSkills.contains(skill) ? proficiencyBonus : 0
        return baseModifier + proficiency
    }
    
    func savingThrowModifier(for ability: AbilityScore) -> Int {
        let baseModifier = modifier(for: score(for: ability))
        let proficiency = proficientSavingThrows.contains(ability) ? proficiencyBonus : 0
        return baseModifier + proficiency
    }
    
    private func abilityScore(for skill: Skill) -> Int {
        switch skill {
        case .athletics: return strength
        case .acrobatics, .sleightOfHand, .stealth: return dexterity
        case .arcana, .history, .investigation, .nature, .religion: return intelligence
        case .animalHandling, .insight, .medicine, .perception, .survival: return wisdom
        case .deception, .intimidation, .performance, .persuasion: return charisma
        }
    }
    
    private func score(for ability: AbilityScore) -> Int {
        switch ability {
        case .strength: return strength
        case .dexterity: return dexterity
        case .constitution: return constitution
        case .intelligence: return intelligence
        case .wisdom: return wisdom
        case .charisma: return charisma
        }
    }
    
    var healthPercentage: Double {
        guard maxHitPoints > 0 else { return 0 }
        return Double(hitPoints) / Double(maxHitPoints)
    }
}

// MARK: - Enums

enum AbilityScore: String, Codable, CaseIterable {
    case strength = "STR"
    case dexterity = "DEX"
    case constitution = "CON"
    case intelligence = "INT"
    case wisdom = "WIS"
    case charisma = "CHA"
    
    var fullName: String {
        switch self {
        case .strength: return "Strength"
        case .dexterity: return "Dexterity"
        case .constitution: return "Constitution"
        case .intelligence: return "Intelligence"
        case .wisdom: return "Wisdom"
        case .charisma: return "Charisma"
        }
    }
    
    var icon: String {
        switch self {
        case .strength: return "figure.strengthtraining.traditional"
        case .dexterity: return "figure.run"
        case .constitution: return "heart.fill"
        case .intelligence: return "brain.head.profile"
        case .wisdom: return "eye.fill"
        case .charisma: return "sparkles"
        }
    }
}

enum Skill: String, Codable, CaseIterable {
    case acrobatics = "Acrobatics"
    case animalHandling = "Animal Handling"
    case arcana = "Arcana"
    case athletics = "Athletics"
    case deception = "Deception"
    case history = "History"
    case insight = "Insight"
    case intimidation = "Intimidation"
    case investigation = "Investigation"
    case medicine = "Medicine"
    case nature = "Nature"
    case perception = "Perception"
    case performance = "Performance"
    case persuasion = "Persuasion"
    case religion = "Religion"
    case sleightOfHand = "Sleight of Hand"
    case stealth = "Stealth"
    case survival = "Survival"
    
    var abilityScore: AbilityScore {
        switch self {
        case .athletics: return .strength
        case .acrobatics, .sleightOfHand, .stealth: return .dexterity
        case .arcana, .history, .investigation, .nature, .religion: return .intelligence
        case .animalHandling, .insight, .medicine, .perception, .survival: return .wisdom
        case .deception, .intimidation, .performance, .persuasion: return .charisma
        }
    }
}

// MARK: - Character Manager

class CharacterManager: ObservableObject {
    static let shared = CharacterManager()
    
    @Published var characters: [PlayerCharacter] = []
    @Published var activeCharacterId: UUID?
    
    private let charactersKey = "playerCharacters"
    private let activeCharacterKey = "activeCharacterId"
    
    init() {
        loadCharacters()
    }
    
    var activeCharacter: PlayerCharacter? {
        guard let id = activeCharacterId else { return nil }
        return characters.first { $0.id == id }
    }
    
    func addCharacter(_ character: PlayerCharacter) {
        characters.append(character)
        if characters.count == 1 {
            activeCharacterId = character.id
        }
        saveCharacters()
    }
    
    func updateCharacter(_ character: PlayerCharacter) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index] = character
            saveCharacters()
        }
    }
    
    func deleteCharacter(_ character: PlayerCharacter) {
        characters.removeAll { $0.id == character.id }
        if activeCharacterId == character.id {
            activeCharacterId = characters.first?.id
        }
        saveCharacters()
    }
    
    func setActiveCharacter(_ character: PlayerCharacter) {
        activeCharacterId = character.id
        UserDefaults.standard.set(character.id.uuidString, forKey: activeCharacterKey)
    }
    
    private func loadCharacters() {
        if let data = UserDefaults.standard.data(forKey: charactersKey),
           let decoded = try? JSONDecoder().decode([PlayerCharacter].self, from: data) {
            characters = decoded
        }
        
        if let idString = UserDefaults.standard.string(forKey: activeCharacterKey),
           let id = UUID(uuidString: idString) {
            activeCharacterId = id
        }
    }
    
    private func saveCharacters() {
        if let encoded = try? JSONEncoder().encode(characters) {
            UserDefaults.standard.set(encoded, forKey: charactersKey)
        }
    }
}
