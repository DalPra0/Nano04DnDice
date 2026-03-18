import SwiftUI
import SwiftData
import RevenueCatUI

struct CampaignManagerView: View {
    @EnvironmentObject private var subManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Campaign.createdDate, order: .reverse) private var campaigns: [Campaign]
    
    @State private var selectedTab = 0
    @State private var showingAddCampaign = false
    @State private var showingAddNPC = false
    @State private var showingAddItem = false
    
    private var activeCampaign: Campaign? {
        campaigns.first { $0.isActive } ?? campaigns.first
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let active = activeCampaign {
                    CampaignHeaderView(campaign: active)
                        .padding(.horizontal)
                        .padding(.top)
                } else {
                    EmptyCampaignView(onCreateCampaign: { 
                        if subManager.canAddItem(currentCount: campaigns.count) {
                            showingAddCampaign = true 
                        } else {
                            subManager.showPaywall = true
                        }
                    })
                        .padding()
                }
                
                if let active = activeCampaign {
                    Picker("View", selection: $selectedTab) {
                        Label("NPCs", systemImage: "person.3.fill").tag(0)
                        Label("Inventory", systemImage: "bag.fill").tag(1)
                        Label("Campaigns", systemImage: "book.fill").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        CampaignNPCsListView(campaign: active)
                            .tag(0)
                        
                        CampaignInventoryListView(campaign: active)
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
                        Button(action: { 
                            if subManager.canAddItem(currentCount: campaigns.count) {
                                showingAddCampaign = true 
                            } else {
                                subManager.showPaywall = true
                            }
                        }) {
                            HStack {
                                Label("New Campaign", systemImage: "plus.circle")
                                if !subManager.isPro { Image(systemName: "crown.fill").foregroundColor(.yellow) }
                            }
                        }
                        
                        if let _ = activeCampaign {
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
                if let campaign = activeCampaign {
                    AddNPCView(campaign: campaign)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                if let campaign = activeCampaign {
                    AddInventoryItemView(campaign: campaign)
                }
            }
            .sheet(isPresented: $subManager.showPaywall) {
                PaywallView(displayCloseButton: true)
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    CampaignManagerView()
}
