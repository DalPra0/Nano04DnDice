
import SwiftUI
import SwiftData
import RevenueCatUI

struct CampaignManagerView: View {
    @EnvironmentObject private var subManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @Query(sort: \Campaign.createdDate, order: .reverse) private var campaigns: [Campaign]
    
    @State private var selectedTab = 0
    @State private var showingAddCampaign = false
    @State private var showingAddNPC = false
    @State private var showingAddItem = false
    
    private var accentColor: Color {
        themeManager.currentTheme.accentColor.color
    }
    
    private var activeCampaign: Campaign? {
        campaigns.first { $0.isActive } ?? campaigns.first
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.black.opacity(0.8), Color.black],
                center: .center,
                startRadius: 100,
                endRadius: 500
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                customHeader
                
                if let active = activeCampaign {
                    VStack(spacing: 0) {
                        // Custom Tab Selector
                        HStack(spacing: 0) {
                            TabButton(title: "NPCS", icon: "person.3.fill", isSelected: selectedTab == 0, accentColor: accentColor) { selectedTab = 0 }
                            TabButton(title: "ITEMS", icon: "bag.fill", isSelected: selectedTab == 1, accentColor: accentColor) { selectedTab = 1 }
                            TabButton(title: "LORE", icon: "book.fill", isSelected: selectedTab == 2, accentColor: accentColor) { selectedTab = 2 }
                        }
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.03))
                        
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
                } else {
                    Spacer()
                    EmptyCampaignView(onCreateCampaign: { 
                        if subManager.canAddItem(currentCount: campaigns.count) {
                            showingAddCampaign = true 
                        } else {
                            subManager.showPaywall = true
                        }
                    })
                    .padding(40)
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
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
    
    private var customHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("CAMPAIGN MANAGER")
                        .font(.custom("PlayfairDisplay-Black", size: 16))
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    if let active = activeCampaign {
                        Text(active.name.uppercased())
                            .font(.custom("PlayfairDisplay-Bold", size: 10))
                            .foregroundColor(accentColor.opacity(0.7))
                            .tracking(1)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(action: { 
                        if subManager.canAddItem(currentCount: campaigns.count) {
                            showingAddCampaign = true 
                        } else {
                            subManager.showPaywall = true
                        }
                    }) {
                        Label("New Campaign", systemImage: "plus.circle")
                    }
                    
                    if activeCampaign != nil {
                        Button(action: { showingAddNPC = true }) {
                            Label("New NPC", systemImage: "person.badge.plus")
                        }
                        
                        Button(action: { showingAddItem = true }) {
                            Label("New Item", systemImage: "bag.badge.plus")
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            LinearGradient(
                colors: [Color.clear, accentColor.opacity(0.5), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
        .background(Color.black.opacity(0.8))
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.custom("PlayfairDisplay-Black", size: 10))
                    .tracking(1)
                
                // Selection Indicator
                Rectangle()
                    .fill(isSelected ? accentColor : Color.clear)
                    .frame(width: 20, height: 2)
                    .cornerRadius(1)
                    .padding(.top, 4)
            }
            .foregroundColor(isSelected ? accentColor : .white.opacity(0.4))
            .frame(maxWidth: .infinity)
        }
    }
}
