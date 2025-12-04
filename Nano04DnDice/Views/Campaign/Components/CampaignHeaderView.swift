import SwiftUI
import Foundation

struct CampaignHeaderView: View {
    let campaign: Campaign
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(campaign.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if !campaign.description.isEmpty {
                        Text(campaign.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
