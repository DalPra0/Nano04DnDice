import SwiftUI
import SwiftData

struct CampaignsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Campaign.createdDate, order: .reverse) private var campaigns: [Campaign]
    @State private var showingEditCampaign: Campaign?
    
    var body: some View {
        Group {
            if !campaigns.isEmpty {
                List {
                    ForEach(campaigns) { campaign in
                        CampaignRowView(campaign: campaign)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Set active campaign logic
                                for c in campaigns {
                                    c.isActive = (c.id == campaign.id)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(campaign)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    showingEditCampaign = campaign
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
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
        .enableInjection()
    }
}
