import SwiftUI
import Foundation

struct EditCampaignView: View {
    @StateObject private var manager = CampaignManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let campaign: Campaign
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Campaign Info")) {
                    TextField("Campaign Name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button(action: {
                        manager.setActiveCampaign(campaign)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Set as Active Campaign")
                        }
                    }
                    .disabled(campaign.id == manager.activeCampaign?.id)
                }
            }
            .navigationTitle("Edit Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCampaign()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = campaign.name
                description = campaign.description
            }
        }
    }
    
    private func saveCampaign() {
        var updated = campaign
        updated.name = name
        updated.description = description
        manager.updateCampaign(updated)
        dismiss()
    }
}
