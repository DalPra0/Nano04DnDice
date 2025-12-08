import SwiftUI
import Foundation

struct CampaignRowView: View {
    @StateObject private var manager = CampaignManager.shared
    let campaign: Campaign
    
    var isActive: Bool {
        campaign.id == manager.activeCampaign?.id
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isActive ? "star.fill" : "book.closed.fill")
                .font(.title3)
                .foregroundColor(isActive ? .yellow : .accentColor)
                .frame(width: 40, height: 40)
                .background(isActive ? Color.yellow.opacity(0.2) : Color.accentColor.opacity(0.2))  // Mantém relativo às cores de tema
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(campaign.name)
                        .font(.headline)
                    
                    if isActive {
                        Text("Active")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                }
                
                if !campaign.description.isEmpty {
                    Text(campaign.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.3.fill")
                            .font(.caption2)
                        Text("\(manager.npcs(for: campaign.id).count) NPCs")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bag.fill")
                            .font(.caption2)
                        Text("\(manager.items(for: campaign.id).count) Items")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !isActive {
                Button(action: {
                    manager.setActiveCampaign(campaign)
                }) {
                    Text("Activate")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}
