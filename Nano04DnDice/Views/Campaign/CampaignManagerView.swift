import Combine
import SwiftUI

struct CampaignManagerView: View {
    @StateObject private var manager = CampaignManager.shared
    @State private var selectedTab = 0
    @State private var showingAddCampaign = false
    @State private var showingAddNPC = false
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let active = manager.activeCampaign {
                    CampaignHeaderView(campaign: active)
                        .padding(.horizontal)
                        .padding(.top)
                } else {
                    EmptyCampaignView(onCreateCampaign: { showingAddCampaign = true })
                        .padding()
                }
                
                if manager.activeCampaign != nil {
                    Picker("View", selection: $selectedTab) {
                        Label("NPCs", systemImage: "person.3.fill").tag(0)
                        Label("Inventory", systemImage: "bag.fill").tag(1)
                        Label("Campaigns", systemImage: "book.fill").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        CampaignNPCsListView()
                            .tag(0)
                        
                        CampaignInventoryListView()
                            .tag(1)
                        
                        CampaignsListView()
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Campaign Manager")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddCampaign = true }) {
                            Label("New Campaign", systemImage: "plus.circle")
                        }
                        
                        if manager.activeCampaign != nil {
                            Button(action: { showingAddNPC = true }) {
                                Label("New NPC", systemImage: "person.badge.plus")
                            }
                            
                            Button(action: { showingAddItem = true }) {
                                Label("New Item", systemImage: "bag.badge.plus")
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCampaign) {
                AddCampaignView()
            }
            .sheet(isPresented: $showingAddNPC) {
                if let campaignId = manager.activeCampaign?.id {
                    AddNPCView(campaignId: campaignId)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                if let campaignId = manager.activeCampaign?.id {
                    AddInventoryItemView(campaignId: campaignId)
                }
            }
        }
    }
}

#Preview {
    CampaignManagerView()
}
