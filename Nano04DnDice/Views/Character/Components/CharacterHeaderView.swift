
import SwiftUI

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
                            .fill(Color.accentColor.opacity(0.2))  // Mantém relativo à cor de acento
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
                            .fill(Color.gray.opacity(0.2))  // Mantém relativo ao gray
                        
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
        .padding(DesignSystem.Spacing.xl + 8)  // 40pt
    }
}
