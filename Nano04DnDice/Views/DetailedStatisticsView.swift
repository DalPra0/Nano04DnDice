
import SwiftUI
import Charts

struct DetailedStatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = DiceRollHistoryManager.shared
    @ObservedObject var themeManager: ThemeManager
    
    @State private var selectedPeriod: StatPeriod = .all
    @State private var selectedDiceFilter: DiceType? = nil
    
    private var currentTheme: DiceCustomization {
        themeManager.currentTheme
    }
    
    private var filteredRolls: [DiceRollEntry] {
        var rolls = historyManager.history
        
        // Filter by period
        switch selectedPeriod {
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            rolls = rolls.filter { $0.timestamp >= today }
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            rolls = rolls.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            rolls = rolls.filter { $0.timestamp >= monthAgo }
        case .all:
            break
        }
        
        // Filter by dice type
        if let diceFilter = selectedDiceFilter {
            rolls = rolls.filter { $0.diceType.sides == diceFilter.sides }
        }
        
        return rolls
    }
    
    private var detailedStats: DetailedStatistics {
        DetailedStatistics(rolls: filteredRolls)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Period Selector
                        periodSelector
                        
                        // Dice Filter
                        diceFilterSelector
                        
                        if !filteredRolls.isEmpty {
                            // Overview Stats
                            overviewCard
                            
                            // Distribution Chart
                            distributionChart
                            
                            // Success Rate by Dice
                            dicePerformanceSection
                            
                            // Roll Mode Statistics
                            rollModeSection
                            
                            // Time-based Analysis
                            timeAnalysisSection
                            
                            // Streaks
                            streaksSection
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Detailed Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(currentTheme.accentColor.color)
                }
            }
        }
    }
    
    private var periodSelector: some View {
        HStack(spacing: 12) {
            ForEach(StatPeriod.allCases, id: \.self) { period in
                Button(action: {
                    selectedPeriod = period
                }) {
                    Text(period.rawValue)
                        .font(.custom("PlayfairDisplay-Regular", size: 14))
                        .foregroundColor(selectedPeriod == period ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                                .fill(selectedPeriod == period ? currentTheme.accentColor.color : DesignSystem.Colors.backgroundOverlay)
                        )
                }
            }
        }
    }
    
    private var diceFilterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {
                    selectedDiceFilter = nil
                }) {
                    Text("All Dice")
                        .font(.custom("PlayfairDisplay-Regular", size: 14))
                        .foregroundColor(selectedDiceFilter == nil ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                                .fill(selectedDiceFilter == nil ? currentTheme.accentColor.color : DesignSystem.Colors.backgroundOverlay)
                        )
                }
                
                ForEach([DiceType.d4, .d6, .d8, .d10, .d12, .d20], id: \.self) { dice in
                    Button(action: {
                        selectedDiceFilter = dice
                    }) {
                        Text(dice.name)
                            .font(.custom("PlayfairDisplay-Regular", size: 14))
                            .foregroundColor(selectedDiceFilter?.sides == dice.sides ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusXLarge)
                                    .fill(selectedDiceFilter?.sides == dice.sides ? currentTheme.accentColor.color : DesignSystem.Colors.backgroundOverlay)
                            )
                    }
                }
            }
        }
    }
    
    private var overviewCard: some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                MiniStatCard(label: "Rolls", value: "\(detailedStats.totalRolls)", color: currentTheme.accentColor.color)
                MiniStatCard(label: "Avg", value: String(format: "%.1f", detailedStats.averageRoll), color: .blue)
                MiniStatCard(label: "Success", value: "\(detailedStats.successRate)%", color: .green)
                MiniStatCard(label: "Criticals", value: "\(detailedStats.criticals)", color: .green)
                MiniStatCard(label: "Fumbles", value: "\(detailedStats.fumbles)", color: .red)
                MiniStatCard(label: "Range", value: "\(detailedStats.lowestRoll)-\(detailedStats.highestRoll)", color: .purple)
            }
        }
        .padding(DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var distributionChart: some View {
        VStack(spacing: 16) {
            Text("Roll Distribution")
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if #available(iOS 16.0, *) {
                Chart(detailedStats.distribution) { item in
                    BarMark(
                        x: .value("Result", item.result),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(currentTheme.accentColor.color)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white)
                    }
                }
            } else {
                // Fallback for iOS 15
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(detailedStats.distribution) { item in
                        VStack {
                            Text("\(item.count)")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                            Rectangle()
                                .fill(currentTheme.accentColor.color)
                                .frame(width: 20, height: CGFloat(item.count) * 10)
                            Text("\(item.result)")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding(DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var dicePerformanceSection: some View {
        VStack(spacing: 16) {
            Text("Dice Performance")
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(detailedStats.dicePerformance, id: \.diceName) { perf in
                DicePerformanceRow(performance: perf, accentColor: currentTheme.accentColor.color)
            }
        }
        .padding(DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var rollModeSection: some View {
        VStack(spacing: 16) {
            Text("Roll Modes")
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(detailedStats.rollModeStats, id: \.mode) { stat in
                RollModeStatRow(stat: stat, accentColor: currentTheme.accentColor.color)
            }
        }
        .padding(DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var timeAnalysisSection: some View {
        VStack(spacing: 16) {
            Text("Activity")
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(detailedStats.mostActiveHour):00")
                        .font(.custom("PlayfairDisplay-Bold", size: 24))
                        .foregroundColor(currentTheme.accentColor.color)
                    Text("Most Active Hour")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack {
                    Text("\(detailedStats.averageRollsPerDay, specifier: "%.1f")")
                        .font(.custom("PlayfairDisplay-Bold", size: 24))
                        .foregroundColor(currentTheme.accentColor.color)
                    Text("Avg Rolls/Day")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 80)
        }
        .padding(DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var streaksSection: some View {
        VStack(spacing: 16) {
            Text("Streaks")
                .font(.custom("PlayfairDisplay-Bold", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StreakCard(
                    label: "Best Streak",
                    value: "\(detailedStats.longestSuccessStreak)",
                    icon: "flame.fill",
                    color: .green
                )
                
                StreakCard(
                    label: "Worst Streak",
                    value: "\(detailedStats.longestFailureStreak)",
                    icon: "snowflake",
                    color: .red
                )
            }
        }
        .padding(DesignSystem.Spacing.lg)  // 20pt→24pt arredondado
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusLarge)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 70))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Data for This Period")
                .font(.custom("PlayfairDisplay-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Try selecting a different period or dice filter")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 100)
    }
}

// MARK: - Supporting Views

struct MiniStatCard: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.custom("PlayfairDisplay-Bold", size: 22))
                .foregroundColor(color)
            
            Text(label)
                .font(.custom("PlayfairDisplay-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct DicePerformanceRow: View {
    let performance: DicePerformance
    let accentColor: Color
    
    var body: some View {
        HStack {
            Text(performance.diceName)
                .font(.custom("PlayfairDisplay-Bold", size: 16))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Avg: \(performance.average, specifier: "%.1f")")
                    Spacer()
                    Text("\(performance.count) rolls")
                }
                .font(.custom("PlayfairDisplay-Regular", size: 12))
                .foregroundColor(.white.opacity(0.8))
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(accentColor)
                            .frame(width: geometry.size.width * CGFloat(performance.successRate / 100), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(.vertical, 8)
    }
}

struct RollModeStatRow: View {
    let stat: RollModeStat
    let accentColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.mode)
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
                    .foregroundColor(.white)
                
                Text("\(stat.count) rolls • Avg: \(stat.average, specifier: "%.1f")")
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("\(stat.percentage)%")
                .font(.custom("PlayfairDisplay-Bold", size: 18))
                .foregroundColor(accentColor)
        }
        .padding(.vertical, 8)
    }
}

struct StreakCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.custom("PlayfairDisplay-Bold", size: 32))
                .foregroundColor(color)
            
            Text(label)
                .font(.custom("PlayfairDisplay-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.radiusMedium)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Enums and Models

enum StatPeriod: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case all = "All Time"
}

struct DetailedStatistics {
    let totalRolls: Int
    let criticals: Int
    let fumbles: Int
    let averageRoll: Double
    let highestRoll: Int
    let lowestRoll: Int
    let successRate: Int
    let distribution: [RollDistribution]
    let dicePerformance: [DicePerformance]
    let rollModeStats: [RollModeStat]
    let mostActiveHour: Int
    let averageRollsPerDay: Double
    let longestSuccessStreak: Int
    let longestFailureStreak: Int
    
    init(rolls: [DiceRollEntry]) {
        totalRolls = rolls.count
        criticals = rolls.filter { $0.isCritical }.count
        fumbles = rolls.filter { $0.isFumble }.count
        
        if !rolls.isEmpty {
            let baseRolls = rolls.map { $0.result - $0.proficiencyBonus }
            averageRoll = Double(baseRolls.reduce(0, +)) / Double(baseRolls.count)
            highestRoll = baseRolls.max() ?? 0
            lowestRoll = baseRolls.min() ?? 0
            
            // Success rate (rolls above half of dice sides)
            let tempTotalRolls = totalRolls
            let successfulRolls = rolls.filter { entry in
                let baseRoll = entry.result - entry.proficiencyBonus
                return Double(baseRoll) > Double(entry.diceType.sides) / 2.0
            }.count
            successRate = Int((Double(successfulRolls) / Double(tempTotalRolls)) * 100)
            
            // Distribution
            let grouped = Dictionary(grouping: baseRolls, by: { $0 })
            distribution = grouped.map { RollDistribution(result: $0.key, count: $0.value.count) }
                .sorted { $0.result < $1.result }
            
            // Dice performance
            let diceGroups = Dictionary(grouping: rolls, by: { $0.diceType.name })
            dicePerformance = diceGroups.map { name, entries in
                let baseRolls = entries.map { $0.result - $0.proficiencyBonus }
                let avg = Double(baseRolls.reduce(0, +)) / Double(baseRolls.count)
                let success = entries.filter { entry in
                    let baseRoll = entry.result - entry.proficiencyBonus
                    return Double(baseRoll) > Double(entry.diceType.sides) / 2.0
                }.count
                let successRate = Double(success) / Double(entries.count) * 100
                
                return DicePerformance(
                    diceName: name,
                    count: entries.count,
                    average: avg,
                    successRate: successRate
                )
            }.sorted { $0.count > $1.count }
            
            // Roll mode stats
            let modeGroups = Dictionary(grouping: rolls, by: { $0.rollMode.rawValue })
            let tempRollModeStats = modeGroups.map { mode, entries -> RollModeStat in
                let baseRolls = entries.map { $0.result - $0.proficiencyBonus }
                let avg = Double(baseRolls.reduce(0, +)) / Double(baseRolls.count)
                let percentage = Int((Double(entries.count) / Double(tempTotalRolls)) * 100)
                
                return RollModeStat(
                    mode: mode,
                    count: entries.count,
                    average: avg,
                    percentage: percentage
                )
            }.sorted { $0.count > $1.count }
            rollModeStats = tempRollModeStats
            
            // Most active hour
            let hours = rolls.map { Calendar.current.component(.hour, from: $0.timestamp) }
            let hourCounts = Dictionary(grouping: hours, by: { $0 }).mapValues { $0.count }
            mostActiveHour = hourCounts.max(by: { $0.value < $1.value })?.key ?? 0
            
            // Average rolls per day
            let days = Set(rolls.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
            averageRollsPerDay = days > 0 ? Double(tempTotalRolls) / Double(days) : 0
            
            // Streaks
            let successStreak = Self.calculateStreak(rolls: rolls.reversed().map { $0 }) { entry in
                let baseRoll = entry.result - entry.proficiencyBonus
                return Double(baseRoll) > Double(entry.diceType.sides) / 2.0
            }
            longestSuccessStreak = successStreak
            
            let failureStreak = Self.calculateStreak(rolls: rolls.reversed().map { $0 }) { entry in
                let baseRoll = entry.result - entry.proficiencyBonus
                return Double(baseRoll) <= Double(entry.diceType.sides) / 2.0
            }
            longestFailureStreak = failureStreak
            
        } else {
            averageRoll = 0
            highestRoll = 0
            lowestRoll = 0
            successRate = 0
            distribution = []
            dicePerformance = []
            rollModeStats = []
            mostActiveHour = 0
            averageRollsPerDay = 0
            longestSuccessStreak = 0
            longestFailureStreak = 0
        }
    }
    
    private static func calculateStreak(rolls: [DiceRollEntry], condition: (DiceRollEntry) -> Bool) -> Int {
        var maxStreak = 0
        var currentStreak = 0
        
        for roll in rolls {
            if condition(roll) {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return maxStreak
    }
}

struct RollDistribution: Identifiable {
    let id = UUID()
    let result: Int
    let count: Int
}

struct DicePerformance {
    let diceName: String
    let count: Int
    let average: Double
    let successRate: Double
}

struct RollModeStat {
    let mode: String
    let count: Int
    let average: Double
    let percentage: Int
}
