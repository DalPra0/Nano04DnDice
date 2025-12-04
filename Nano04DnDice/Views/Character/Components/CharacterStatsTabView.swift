
import SwiftUI

struct CharacterStatsTabView: View {
    let character: PlayerCharacter
    @StateObject private var manager = CharacterManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    QuickStatCard(title: "Prof Bonus", value: "+\(character.proficiencyBonus)", icon: "plus.circle.fill", color: .blue)
                    QuickStatCard(title: "Initiative", value: formatModifier(character.dexModifier), icon: "bolt.fill", color: .yellow)
                    QuickStatCard(title: "Speed", value: "\(character.speed) ft", icon: "figure.walk", color: .green)
                }
                .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(AbilityScore.allCases, id: \.self) { ability in
                        AbilityScoreCard(ability: ability, character: character)
                    }
                }
                .padding(.horizontal)
                
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
