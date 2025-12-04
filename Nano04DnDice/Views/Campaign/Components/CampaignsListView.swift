import SwiftUI
import Foundation

struct CampaignsListView: View {
    @StateObject private var manager = CampaignManager.shared
    @State private var showingEditCampaign: Campaign?
    
    var body: some View {
        Group {
            if !manager.campaigns.isEmpty {
                List {
                    ForEach(manager.campaigns) { campaign in
                        CampaignRowView(campaign: campaign)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if campaign.id != manager.activeCampaign?.id {
                                    showingEditCampaign = campaign
                                }
                            }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let campaign = manager.campaigns[index]
                            manager.deleteCampaign(campaign)
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No Campaigns Yet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Create a campaign using the + button")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(item: $showingEditCampaign) { campaign in
            EditCampaignView(campaign: campaign)
        }
    }
}
