import SwiftUI
import SwiftData

struct EditInventoryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: InventoryItem
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    TextField("Item Name", text: $item.name)
                    TextField("Description", text: $item.itemDescription, axis: .vertical)
                        .lineLimit(3...5)
                    Picker("Category", selection: $item.category) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Stats")) {
                    Stepper("Quantity: \(item.quantity)", value: $item.quantity, in: 1...999)
                    HStack {
                        Text("Value (gp)")
                        Spacer()
                        TextField("Value", value: $item.value, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Weight (lb)")
                        Spacer()
                        TextField("Weight", value: $item.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}