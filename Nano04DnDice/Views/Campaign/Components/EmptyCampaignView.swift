import SwiftUI
import Foundation

struct EmptyCampaignView: View {
    let onCreateCampaign: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Active Campaign")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a campaign to start managing NPCs and inventory")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onCreateCampaign) {
                Label("Create Campaign", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
