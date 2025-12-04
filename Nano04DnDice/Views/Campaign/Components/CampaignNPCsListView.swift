import SwiftUI
import Foundation

struct CampaignNPCsListView: View {
    @StateObject private var manager = CampaignManager.shared
    @State private var showingEditNPC: NPC?
    
    var npcs: [NPC] {
        guard let campaignId = manager.activeCampaign?.id else { return [] }
        return manager.npcs(for: campaignId)
    }
    
    var body: some View {
        Group {
            if manager.activeCampaign != nil && !npcs.isEmpty {
                List {
                    ForEach(npcs) { npc in
                        NPCRowView(npc: npc)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showingEditNPC = npc
                            }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let npc = npcs[index]
                            manager.deleteNPC(npc)
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
            if let campaignId = manager.activeCampaign?.id {
                EditNPCView(campaignId: campaignId, npc: npc)
            }
        }
    }
}
