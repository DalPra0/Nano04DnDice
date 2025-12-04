import SwiftUI
import Foundation

struct CampaignInventoryListView: View {
    @StateObject private var manager = CampaignManager.shared
    @State private var selectedCategory: ItemCategory?
    @State private var showingEditItem: InventoryItem?
    
    var filteredItems: [InventoryItem] {
        guard let campaignId = manager.activeCampaign?.id else { return [] }
        let items = manager.items(for: campaignId)
        if let category = selectedCategory {
            return items.filter { $0.category == category }
        }
        return items
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryFilterButton(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(ItemCategory.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            title: category.rawValue.capitalized,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding()
            }
            
            // Items List
            if !filteredItems.isEmpty {
                List {
                    ForEach(filteredItems) { item in
                        InventoryItemRowView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showingEditItem = item
                            }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let item = filteredItems[index]
                            manager.deleteItem(item)
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "bag")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No Items Yet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Add items using the + button")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(item: $showingEditItem) { item in
            if let campaignId = manager.activeCampaign?.id {
                EditInventoryItemView(campaignId: campaignId, item: item)
            }
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}
