import SwiftUI
import Foundation

struct AddInventoryItemView: View {
    @StateObject private var manager = CampaignManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let campaignId: UUID
    
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
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addItem() {
        let item = InventoryItem(
            campaignId: campaignId,
            name: name,
            description: description, quantity: quantity, category: category,
            value: value,
            weight: weight,
            isEquipped: isEquipped
        )
        manager.addItem(item)
        dismiss()
    }
}
