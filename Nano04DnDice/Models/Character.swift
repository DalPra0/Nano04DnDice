
import Foundation
import SwiftData
import SwiftUI

@Model
final class PlayerCharacter {
    @Attribute(.unique) var id: UUID
    var name: String
    var characterClass: String
    var race: String
    var level: Int
    var experiencePoints: Int
    
    // Ability Scores
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
    var proficientSkillsStrings: [String]
    var proficientSavingThrowsStrings: [String]
    
    // Equipment
    var equippedWeapon: String
    var equippedArmor: String
    var equippedItems: [String]
    
    // Notes
    var notes: String
    var backstory: String
    
    var isActive: Bool = false
    
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
        self.proficientSkillsStrings = proficientSkills.map { $0.rawValue }
        self.proficientSavingThrowsStrings = proficientSavingThrows.map { $0.rawValue }
        self.equippedWeapon = equippedWeapon
        self.equippedArmor = equippedArmor
        self.equippedItems = equippedItems
        self.notes = notes
        self.backstory = backstory
    }
    
    // Modifiers
    func modifier(for score: Int) -> Int {
        return (score - 10) / 2
    }
    
    var strModifier: Int { modifier(for: strength) }
    var dexModifier: Int { modifier(for: dexterity) }
    var conModifier: Int { modifier(for: constitution) }
    var intModifier: Int { modifier(for: intelligence) }
    var wisModifier: Int { modifier(for: wisdom) }
    var chaModifier: Int { modifier(for: charisma) }
    
    var healthPercentage: Double {
        guard maxHitPoints > 0 else { return 0 }
        return Double(hitPoints) / Double(maxHitPoints)
    }

    var proficientSkills: [Skill] {
        get { proficientSkillsStrings.compactMap { Skill(rawValue: $0) } }
        set { proficientSkillsStrings = newValue.map { $0.rawValue } }
    }
    
    var proficientSavingThrows: [AbilityScore] {
        get { proficientSavingThrowsStrings.compactMap { AbilityScore(rawValue: $0) } }
        set { proficientSavingThrowsStrings = newValue.map { $0.rawValue } }
    }
    
    func savingThrowModifier(for score: AbilityScore) -> Int {
        let baseModifier: Int
        switch score {
        case .strength: baseModifier = strModifier
        case .dexterity: baseModifier = dexModifier
        case .constitution: baseModifier = conModifier
        case .intelligence: baseModifier = intModifier
        case .wisdom: baseModifier = wisModifier
        case .charisma: baseModifier = chaModifier
        }
        
        if proficientSavingThrows.contains(score) {
            return baseModifier + proficiencyBonus
        }
        return baseModifier
    }
}

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
