import SwiftUI
import SwiftData

struct CampaignNPCsListView: View {
    @Environment(\.modelContext) private var modelContext
    let campaign: Campaign
    @State private var showingEditNPC: NPC?
    
    var body: some View {
        Group {
            if !campaign.npcs.isEmpty {
                List {
                    ForEach(campaign.npcs.sorted(by: { $0.name < $1.name })) { npc in
                        NPCRowView(npc: npc)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showingEditNPC = npc
                            }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let npc = campaign.npcs.sorted(by: { $0.name < $1.name })[index]
                            modelContext.delete(npc)
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "person.3")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No NPCs Yet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Add NPCs using the + button")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(item: $showingEditNPC) { npc in
            EditNPCView(npc: npc)
        }
        .enableInjection()
    }
}
