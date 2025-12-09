
import SwiftUI

struct DiceRollHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = DiceRollHistoryManager.shared
    @State private var showStatistics = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                if historyManager.history.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20, pinnedViews: []) {
                            statisticsCard
                            
                            Divider()
                                .background(DesignSystem.Colors.borderSubtle)
                                .padding(.vertical, 10)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(historyManager.history) { entry in
                                    HistoryEntryCard(entry: entry)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Roll History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.brandGold)
                }
                
                if !historyManager.history.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            historyManager.clearHistory()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .accessibilityLabel("Clear history")
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 70))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Roll History")
                .font(.custom("PlayfairDisplay-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Your dice rolls will appear here")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private var statisticsCard: some View {
        let stats = historyManager.getStatistics()
        
        return VStack(spacing: 16) {
            Text("Statistics")
                .font(.custom("PlayfairDisplay-Bold", size: 22))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatItem(label: "Total Rolls", value: "\(stats.totalRolls)")
                StatItem(label: "Average", value: String(format: "%.1f", stats.averageRoll))
                StatItem(label: "Criticals", value: "\(stats.criticals)", color: .green)
                StatItem(label: "Fumbles", value: "\(stats.fumbles)", color: .red)
                StatItem(label: "Highest", value: "\(stats.highestRoll)")
                StatItem(label: "Lowest", value: "\(stats.lowestRoll)")
            }
            
            Text("Most Used: \(stats.mostUsedDice)")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundColor(DesignSystem.Colors.brandGold)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                .fill(DesignSystem.Colors.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)  // Mantém relativo ao amarelo
        )
        .padding(.horizontal, 20)
    }
}

struct HistoryEntryCard: View {
    let entry: DiceRollEntry
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: entry.timestamp, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.diceType.name)
                        .font(DesignSystem.Typography.bodyLarge)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    if entry.rollMode != .normal {
                        Text(entry.rollMode.displayName.uppercased())
                            .font(.custom("PlayfairDisplay-Bold", size: 10))
                            .foregroundColor(entry.rollMode == .blessed ? .green : .red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill((entry.rollMode == .blessed ? Color.green : Color.red).opacity(0.2))
                            )
                    }
                }
                
                Text(timeAgo)
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if let second = entry.secondResult {
                    Text("[\(second)]")
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .foregroundColor(DesignSystem.Colors.textDisabled)
                        .strikethrough()
                }
                
                Text("\(entry.result)")
                    .font(.custom("PlayfairDisplay-Black", size: 32))
                    .foregroundColor(entry.isCritical ? DesignSystem.Colors.success : entry.isFumble ? DesignSystem.Colors.error : DesignSystem.Colors.brandGold)
                
                if entry.isCritical {
                    Image(systemName: "star.fill")
                        .foregroundColor(DesignSystem.Colors.success)
                } else if entry.isFumble {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(DesignSystem.Colors.error)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                .fill(DesignSystem.Colors.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                        .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
                )
        )
    }
}

struct StatItem: View {
    let label: String
    let value: String
    var color: Color = .white
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("PlayfairDisplay-Black", size: 24))
                .foregroundColor(color)
            
            Text(label)
                .font(.custom("PlayfairDisplay-Regular", size: 12))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusSmall + 2)
                .fill(DesignSystem.Colors.backgroundOverlay)
        )
    }
}

#Preview {
    DiceRollHistoryView()
}
