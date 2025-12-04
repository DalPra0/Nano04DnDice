import SwiftUI
import Foundation

struct InventoryItemRowView: View {
    let item: InventoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: categoryIcon)
                .font(.title3)
                .foregroundColor(categoryColor)
                .frame(width: 40, height: 40)
                .background(categoryColor.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(item.category.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if item.quantity > 1 {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("x\(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if item.isEquipped {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("Equipped")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if item.value > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("\(item.value)gp")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                if item.weight > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "scalemass.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", item.weight))lb")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var categoryIcon: String {
        switch item.category {
        case .weapon: return "sword.fill"
        case .armor: return "shield.fill"
        case .potion: return "flask.fill"
        case .scroll: return "scroll.fill"
        case .misc: return "cube.fill"
        case .quest: return "star.fill"
        case .treasure: return "crown.fill"
        }
    }
    
    private var categoryColor: Color {
        switch item.category {
        case .weapon: return .red
        case .armor: return .blue
        case .potion: return .green
        case .scroll: return .purple
        case .misc: return .gray
        case .quest: return .orange
        case .treasure: return .yellow
        }
    }
}
