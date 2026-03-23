import SwiftUI
import SwiftData

struct InitiativeTrackerView: View {
    @Bindable var campaign: Campaign
    @State private var newName: String = ""
    @State private var newInitiative: String = ""
    @State private var isAlly: Bool = false
    
    var body: some View {
        VStack {
            // Sort list by initiative descending
            List {
                let sortedTracker = (campaign.combatTracker ?? []).sorted { $0.initiative > $1.initiative }
                
                ForEach(sortedTracker) { item in
                    HStack {
                        Circle()
                            .fill(item.isAlly ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        Text(item.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(item.initiative)")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            if let index = campaign.combatTracker?.firstIndex(where: { $0.id == item.id }) {
                                campaign.combatTracker?.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            
            // Add new entity
            VStack(spacing: 12) {
                HStack {
                    TextField("Name (e.g., Goblin)", text: $newName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Init", text: $newInitiative)
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                }
                
                Toggle("Is Ally / Player?", isOn: $isAlly)
                    .padding(.horizontal, 4)
                
                Button(action: {
                    if let initValue = Int(newInitiative), !newName.isEmpty {
                        if campaign.combatTracker == nil { campaign.combatTracker = [] }
                        let newItem = InitiativeTrackerItem(name: newName, initiative: initValue, isAlly: isAlly)
                        campaign.combatTracker?.append(newItem)
                        newName = ""
                        newInitiative = ""
                        isAlly = false
                    }
                }) {
                    Text("ADD TO TRACKER")
                        .font(.custom("PlayfairDisplay-Black", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding()
        }
    }
}
