
import SwiftUI

struct AbilityScoreRow: View {
    let title: String
    let icon: String
    @Binding var value: Int
    
    var modifier: Int {
        (value - 10) / 2
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(title)
            
            Spacer()
            
            Text(formatModifier(modifier))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            Stepper("\(value)", value: $value, in: 3...30)
                .labelsHidden()
        }
    }
    
    private func formatModifier(_ value: Int) -> String {
        return value >= 0 ? "+\(value)" : "\(value)"
    }
}
