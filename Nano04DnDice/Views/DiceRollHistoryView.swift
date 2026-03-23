
import SwiftUI

struct DiceRollHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = DiceRollHistoryManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    private var accentColor: Color {
        themeManager.currentTheme.accentColor.color
    }
    
    var body: some View {
        ZStack {
            // Background - Deep dark with a slight radial gradient for depth
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
                
                if historyManager.history.isEmpty {
                    Spacer()
                    emptyStateView
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            statisticsSection
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("CHRONICLES")
                                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                                    .foregroundColor(accentColor.opacity(0.7))
                                    .tracking(4)
                                    .padding(.horizontal, 4)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(historyManager.history) { entry in
                                        HistoryEntryCard(entry: entry, accentColor: accentColor)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                        .padding(.top, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
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
                
                Text("ROLL HISTORY")
                    .font(.custom("PlayfairDisplay-Black", size: 20))
                    .foregroundColor(.white)
                    .tracking(2)
                
                Spacer()
                
                if !historyManager.history.isEmpty {
                    Button(action: { historyManager.clearHistory() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.red.opacity(0.8))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.red.opacity(0.1)))
                    }
                } else {
                    Spacer().frame(width: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Decorative line
            LinearGradient(
                colors: [Color.clear, accentColor.opacity(0.5), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
        .background(Color.black.opacity(0.8))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "scroll.fill")
                    .font(.system(size: 50))
                    .foregroundColor(accentColor.opacity(0.5))
            }
            
            VStack(spacing: 8) {
                Text("The Archives are Empty")
                    .font(.custom("PlayfairDisplay-Bold", size: 24))
                    .foregroundColor(.white)
                
                Text("Your legendary deeds have not yet been recorded.")
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private var statisticsSection: some View {
        let stats = historyManager.getStatistics()
        
        return VStack(spacing: 20) {
            HStack {
                Text("INSIGHTS")
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(accentColor.opacity(0.7))
                    .tracking(4)
                Spacer()
                Text("Most Used: \(stats.mostUsedDice)")
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(accentColor.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 24)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(label: "Total", value: "\(stats.totalRolls)", icon: "dice.fill", accentColor: accentColor)
                StatCard(label: "Average", value: String(format: "%.1f", stats.averageRoll), icon: "chart.bar.fill", accentColor: accentColor)
                StatCard(label: "Highest", value: "\(stats.highestRoll)", icon: "arrow.up.circle.fill", accentColor: .green)
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 12) {
                StatCardMini(label: "Criticals", value: "\(stats.criticals)", color: .green)
                StatCardMini(label: "Fumbles", value: "\(stats.fumbles)", color: .red)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(accentColor.opacity(0.7))
            
            Text(value)
                .font(.custom("PlayfairDisplay-Black", size: 22))
                .foregroundColor(.white)
            
            Text(label.uppercased())
                .font(.custom("PlayfairDisplay-Bold", size: 10))
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accentColor.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct StatCardMini: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            Spacer()
            Text(value)
                .font(.custom("PlayfairDisplay-Black", size: 18))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct HistoryEntryCard: View {
    let entry: DiceRollEntry
    let accentColor: Color
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: entry.timestamp, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Dice Icon based on type
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text(entry.diceType.name.replacingOccurrences(of: "d", with: ""))
                    .font(.custom("PlayfairDisplay-Black", size: 14))
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(entry.diceType.name)
                        .font(.custom("PlayfairDisplay-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    if entry.rollMode != .normal {
                        Text(entry.rollMode.displayName.uppercased())
                            .font(.custom("PlayfairDisplay-Black", size: 8))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(entry.rollMode == .blessed ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .foregroundColor(entry.rollMode == .blessed ? .green : .red)
                            .cornerRadius(4)
                    }
                }
                
                Text(timeAgo)
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
            
            // Result Section
            HStack(spacing: 8) {
                if let second = entry.secondResult {
                    Text("\(second)")
                        .font(.custom("PlayfairDisplay-Bold", size: 14))
                        .foregroundColor(DesignSystem.Colors.textDisabled)
                        .strikethrough()
                }
                
                Text("\(entry.result)")
                    .font(.custom("PlayfairDisplay-Black", size: 28))
                    .foregroundColor(entry.isCritical ? .green : entry.isFumble ? .red : accentColor)
                    .shadow(color: (entry.isCritical ? Color.green : entry.isFumble ? Color.red : Color.clear).opacity(0.5), radius: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            entry.isCritical ? Color.green.opacity(0.3) : 
                            entry.isFumble ? Color.red.opacity(0.3) : 
                            Color.white.opacity(0.1), 
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview {
    DiceRollHistoryView()
}
