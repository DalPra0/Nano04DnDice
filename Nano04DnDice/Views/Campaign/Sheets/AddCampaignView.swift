import SwiftUI
import Foundation

struct AddCampaignView: View {
    @StateObject private var manager = CampaignManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var setAsActive = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Campaign Info")) {
                    TextField("Campaign Name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Toggle("Set as Active Campaign", isOn: $setAsActive)
                }
            }
            .navigationTitle("New Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addCampaign()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addCampaign() {
        let campaign = Campaign(name: name, description: description, isActive: setAsActive)
        manager.addCampaign(campaign)
        if setAsActive {
            manager.setActiveCampaign(campaign)
        }
        dismiss()
    }
}
