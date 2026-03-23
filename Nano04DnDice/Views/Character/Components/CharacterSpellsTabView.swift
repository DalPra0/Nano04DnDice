import SwiftUI
import SwiftData

struct CharacterSpellsTabView: View {
    @Bindable var character: PlayerCharacter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Spellcasting Info
                HStack {
                    VStack {
                        Text("Ability")
                            .font(.caption).foregroundColor(.secondary)
                        Text(character.spellcastingAbility ?? "INT")
                            .font(.headline)
                    }
                    Spacer()
                    VStack {
                        Text("Save DC")
                            .font(.caption).foregroundColor(.secondary)
                        Text("\(8 + character.proficiencyBonus + spellcastingModifier)")
                            .font(.headline)
                    }
                    Spacer()
                    VStack {
                        Text("Attack Bonus")
                            .font(.caption).foregroundColor(.secondary)
                        Text("+\(character.proficiencyBonus + spellcastingModifier)")
                            .font(.headline)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                
                // Spell Slots Tracking
                VStack(alignment: .leading, spacing: 12) {
                    Text("Spell Slots")
                        .font(.headline)
                    
                    ForEach(1...9, id: \.self) { level in
                        let slots = character.spellSlots ?? Array(repeating: SpellSlotStatus(), count: 9)
                        if level <= slots.count && slots[level - 1].total > 0 {
                            HStack {
                                Text("Lvl \(level)")
                                    .frame(width: 50, alignment: .leading)
                                
                                HStack {
                                    ForEach(0..<slots[level - 1].total, id: \.self) { index in
                                        Circle()
                                            .fill(index < slots[level - 1].used ? Color.accentColor : Color.gray.opacity(0.3))
                                            .frame(width: 20, height: 20)
                                            .onTapGesture {
                                                if character.spellSlots == nil {
                                                    character.spellSlots = Array(repeating: SpellSlotStatus(), count: 9)
                                                }
                                                if index < character.spellSlots![level - 1].used {
                                                    character.spellSlots![level - 1].used -= 1
                                                } else {
                                                    character.spellSlots![level - 1].used += 1
                                                }
                                            }
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                
                // Spells List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Spells")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            if character.spells == nil { character.spells = [] }
                            let newSpell = CharacterSpell(name: "New Spell", level: 1)
                            character.spells?.append(newSpell)
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    
                    if (character.spells ?? []).isEmpty {
                        Text("No spells added.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(0...9, id: \.self) { level in
                            let levelSpells = (character.spells ?? []).filter { $0.level == level }
                            if !levelSpells.isEmpty {
                                Text(level == 0 ? "Cantrips" : "Level \(level)")
                                    .font(.subheadline)
                                    .bold()
                                    .padding(.top, 4)
                                
                                ForEach(levelSpells) { spell in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(spell.name).font(.body)
                                            Text("\(spell.castingTime) • \(spell.range)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: spell.isPrepared ? "star.fill" : "star")
                                            .foregroundColor(.accentColor)
                                            .onTapGesture {
                                                if let index = character.spells?.firstIndex(where: { $0.id == spell.id }) {
                                                    character.spells?[index].isPrepared.toggle()
                                                }
                                            }
                                    }
                                    .padding(.vertical, 4)
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            }
            .padding()
        }
    }
    
    private var spellcastingModifier: Int {
        switch character.spellcastingAbility ?? "INT" {
        case "INT": return character.intModifier
        case "WIS": return character.wisModifier
        case "CHA": return character.chaModifier
        default: return 0
        }
    }
}
