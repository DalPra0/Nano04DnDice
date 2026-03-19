import SwiftUI
import SwiftData

struct CampaignRowView: View {
    @Environment(\.modelContext) private var modelContext
    let campaign: Campaign
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: campaign.isActive ? "star.fill" : "book.closed.fill")
                .font(.title3)
                .foregroundColor(campaign.isActive ? .yellow : .accentColor)
                .frame(width: 40, height: 40)
                .background(campaign.isActive ? Color.yellow.opacity(0.2) : Color.accentColor.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(campaign.name)
                        .font(.headline)
                    
                    if campaign.isActive {
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
                
                if !campaign.campaignDescription.isEmpty {
                    Text(campaign.campaignDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.3.fill")
                            .font(.caption2)
                        Text("\(campaign.npcs.count) NPCs")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bag.fill")
                            .font(.caption2)
                        Text("\(campaign.inventory.count) Items")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .enableInjection()
    }
}