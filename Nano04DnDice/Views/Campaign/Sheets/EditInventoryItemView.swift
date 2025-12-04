import SwiftUI
import Foundation

struct EditInventoryItemView: View {
    @StateObject private var manager = CampaignManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let campaignId: UUID
    let item: InventoryItem
    
    @State private var name = ""
    @State private var category: ItemCategory = .misc
    @State private var quantity = 1
    @State private var value = 0
    @State private var weight: Double = 0.0
    @State private var description = ""
    @State private var isEquipped = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    TextField("Item Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)
                }
                
                Section(header: Text("Properties")) {
                    Stepper("Value: \(value) gp", value: $value, in: 0...999999)
                    
                    HStack {
                        Text("Weight:")
                        Spacer()
                        TextField("0.0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("lb")
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Equipped", isOn: $isEquipped)
                }
                
                Section(header: Text("Description")) {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = item.name
                category = item.category
                quantity = item.quantity
                value = item.value
                weight = item.weight
                description = item.description
                isEquipped = item.isEquipped
            }
        }
    }
    
    private func saveItem() {
        var updated = item
        updated.name = name
        updated.category = category
        updated.quantity = quantity
        updated.value = value
        updated.weight = weight
        updated.description = description
        updated.isEquipped = isEquipped
        
        manager.updateItem(updated)
        dismiss()
    }
}
