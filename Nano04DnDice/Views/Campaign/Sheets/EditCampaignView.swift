import SwiftUI
import SwiftData

struct EditCampaignView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var campaign: Campaign
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Campaign Details")) {
                    TextField("Campaign Name", text: $campaign.name)
                    TextField("Description", text: $campaign.campaignDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}