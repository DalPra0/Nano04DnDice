
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
                // Campaign Selector
                if let active = manager.activeCampaign {
                    CampaignHeaderView(campaign: active)
                        .padding(.horizontal)
                        .padding(.top)
                } else {
                    EmptyCampaignView(onCreateCampaign: { showingAddCampaign = true })
                        .padding()
                }
                
                // Tab Selector
                if manager.activeCampaign != nil {
                    Picker("View", selection: $selectedTab) {
                        Label("NPCs", systemImage: "person.3.fill").tag(0)
                        Label("Inventory", systemImage: "bag.fill").tag(1)
                        Label("Campaigns", systemImage: "book.fill").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        NPCsListView()
                            .tag(0)
                        
                        InventoryListView()
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

// MARK: - Campaign Header

struct CampaignHeaderView: View {
    let campaign: Campaign
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.accentColor)
                Text(campaign.name)
                    .font(.headline)
                Spacer()
            }
            
            if !campaign.description.isEmpty {
                Text(campaign.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Empty Campaign View

struct EmptyCampaignView: View {
    let onCreateCampaign: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Active Campaign")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a campaign to start tracking NPCs and inventory")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onCreateCampaign) {
                Label("Create Campaign", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
}

// MARK: - NPCs List

struct NPCsListView: View {
    @StateObject private var manager = CampaignManager.shared
    @State private var selectedNPC: NPC?
    @State private var showingEditNPC = false
    
    var npcs: [NPC] {
        guard let campaignId = manager.activeCampaign?.id else { return [] }
        return manager.npcs(for: campaignId)
    }
    
    var body: some View {
        List {
            if npcs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No NPCs yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(npcs) { npc in
                    NPCRowView(npc: npc)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedNPC = npc
                            showingEditNPC = true
                        }
                }
                .onDelete(perform: deleteNPCs)
            }
        }
        .listStyle(.plain)
        .sheet(item: $selectedNPC) { npc in
            EditNPCView(npc: npc)
        }
    }
    
    private func deleteNPCs(at offsets: IndexSet) {
        for index in offsets {
            manager.deleteNPC(npcs[index])
        }
    }
}

struct NPCRowView: View {
    let npc: NPC
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(npc.isAlly ? Color.blue.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: npc.isAlly ? "person.fill" : "person.fill.xmark")
                    .foregroundColor(npc.isAlly ? .blue : .red)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(npc.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if !npc.race.isEmpty {
                        Text(npc.race)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if !npc.characterClass.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(npc.characterClass)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if npc.level > 1 {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("Lvl \(npc.level)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Health Bar
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("\(npc.hitPoints)/\(npc.maxHitPoints) HP")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("AC \(npc.armorClass)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                            
                            Rectangle()
                                .fill(npc.healthColor)
                                .frame(width: geometry.size.width * npc.healthPercentage)
                        }
                        .frame(height: 4)
                        .cornerRadius(2)
                    }
                    .frame(height: 4)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Inventory List

struct InventoryListView: View {
    @StateObject private var manager = CampaignManager.shared
    @State private var selectedItem: InventoryItem?
    @State private var filterCategory: ItemCategory?
    
    var items: [InventoryItem] {
        guard let campaignId = manager.activeCampaign?.id else { return [] }
        let allItems = manager.items(for: campaignId)
        
        if let filter = filterCategory {
            return allItems.filter { $0.category == filter }
        }
        return allItems
    }
    
    var totalValue: Int {
        guard let campaignId = manager.activeCampaign?.id else { return 0 }
        return manager.totalValue(for: campaignId)
    }
    
    var totalWeight: Double {
        guard let campaignId = manager.activeCampaign?.id else { return 0 }
        return manager.totalWeight(for: campaignId)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats Header
            HStack(spacing: 20) {
                VStack {
                    Text("\(totalValue)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Gold")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                VStack {
                    Text(String(format: "%.1f", totalWeight))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("lbs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                VStack {
                    Text("\(items.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryFilterButton(category: nil, isSelected: filterCategory == nil) {
                        filterCategory = nil
                    }
                    
                    ForEach(ItemCategory.allCases, id: \.self) { category in
                        CategoryFilterButton(category: category, isSelected: filterCategory == category) {
                            filterCategory = category
                        }
                    }
                }
                .padding()
            }
            
            // Items List
            List {
                if items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bag")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No items yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(items) { item in
                        InventoryItemRowView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedItem = item
                            }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .listStyle(.plain)
        }
        .sheet(item: $selectedItem) { item in
            EditInventoryItemView(item: item)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            manager.deleteItem(items[index])
        }
    }
}

struct CategoryFilterButton: View {
    let category: ItemCategory?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let cat = category {
                    Image(systemName: cat.icon)
                    Text(cat.rawValue)
                } else {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text("All")
                }
            }
            .font(.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct InventoryItemRowView: View {
    let item: InventoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(item.category.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: item.category.icon)
                    .foregroundColor(item.category.color)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    
                    if item.isEquipped {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 12) {
                    Label("\(item.quantity)", systemImage: "number")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Label("\(item.value) gp", systemImage: "centsign.circle")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if item.weight > 0 {
                        Label(String(format: "%.1f lbs", item.weight), systemImage: "scalemass")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Campaigns List

struct CampaignsListView: View {
    @StateObject private var manager = CampaignManager.shared
    @State private var selectedCampaign: Campaign?
    @State private var showingAddCampaign = false
    
    var body: some View {
        List {
            ForEach(manager.campaigns) { campaign in
                CampaignRowView(campaign: campaign)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCampaign = campaign
                    }
            }
            .onDelete(perform: deleteCampaigns)
        }
        .listStyle(.plain)
        .overlay {
            if manager.campaigns.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No campaigns yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(item: $selectedCampaign) { campaign in
            EditCampaignView(campaign: campaign)
        }
    }
    
    private func deleteCampaigns(at offsets: IndexSet) {
        for index in offsets {
            manager.deleteCampaign(manager.campaigns[index])
        }
    }
}

struct CampaignRowView: View {
    @StateObject private var manager = CampaignManager.shared
    let campaign: Campaign
    
    var npcCount: Int {
        manager.npcs(for: campaign.id).count
    }
    
    var itemCount: Int {
        manager.items(for: campaign.id).count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(campaign.isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: campaign.isActive ? "book.fill" : "book")
                    .foregroundColor(campaign.isActive ? .green : .gray)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(campaign.name)
                        .font(.headline)
                    
                    if campaign.isActive {
                        Text("ACTIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                }
                
                if !campaign.description.isEmpty {
                    Text(campaign.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    Label("\(npcCount) NPCs", systemImage: "person.2")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Label("\(itemCount) Items", systemImage: "bag")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                manager.setActiveCampaign(campaign)
            }) {
                Image(systemName: campaign.isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(campaign.isActive ? .green : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CampaignManagerView()
}
