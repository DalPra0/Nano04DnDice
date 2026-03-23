
import SwiftUI
import Charts

struct DetailedStatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = DiceRollHistoryManager.shared
    @ObservedObject var themeManager: ThemeManager
    
    @State private var selectedPeriod: StatPeriod = .all
    @State private var selectedDiceFilter: DiceType? = nil
    
    private var accentColor: Color {
        themeManager.currentTheme.accentColor.color
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
        ZStack {
            // Background
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Filters Section
                        VStack(spacing: 16) {
                            periodSelector
                            diceFilterSelector
                        }
                        .padding(.top, 20)
                        
                        if !filteredRolls.isEmpty {
                            // Overview Stats
                            overviewSection
                            
                            // Distribution Chart
                            distributionSection
                            
                            // Performance Analysis
                            VStack(spacing: 24) {
                                sectionHeader("PROWESS BY DICE")
                                dicePerformanceSection
                            }
                            
                            // Activity Analysis
                            VStack(spacing: 24) {
                                sectionHeader("CHRONICLE ACTIVITY")
                                timeAnalysisSection
                                streaksSection
                            }
                            
                            Spacer().frame(height: 40)
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var customHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentColor)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text("DETAILED INSIGHTS")
                    .font(.custom("PlayfairDisplay-Black", size: 18))
                    .foregroundColor(.white)
                    .tracking(2)
                
                Spacer()
                
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            LinearGradient(
                colors: [Color.clear, accentColor.opacity(0.5), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
        }
        .background(Color.black.opacity(0.8))
    }
    
    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.custom("PlayfairDisplay-Bold", size: 12))
                .foregroundColor(accentColor.opacity(0.8))
                .tracking(3)
            Spacer()
            Rectangle()
                .fill(accentColor.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.horizontal, 4)
    }
    
    private var periodSelector: some View {
        HStack(spacing: 8) {
            ForEach(StatPeriod.allCases, id: \.self) { period in
                Button(action: { selectedPeriod = period }) {
                    Text(period.rawValue.uppercased())
                        .font(.custom("PlayfairDisplay-Bold", size: 10))
                        .foregroundColor(selectedPeriod == period ? .black : .white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedPeriod == period ? accentColor : Color.white.opacity(0.05))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedPeriod == period ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
            }
        }
    }
    
    private var diceFilterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    text: "ALL", 
                    isSelected: selectedDiceFilter == nil, 
                    accentColor: accentColor, 
                    action: { selectedDiceFilter = nil }
                )
                
                ForEach([DiceType.d4, .d6, .d8, .d10, .d12, .d20], id: \.self) { dice in
                    FilterChip(
                        text: dice.name, 
                        isSelected: selectedDiceFilter?.sides == dice.sides, 
                        accentColor: accentColor, 
                        action: { selectedDiceFilter = dice }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var overviewSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                StatPanel(label: "TOTAL ROLLS", value: "\(detailedStats.totalRolls)", color: .white, accentColor: accentColor)
                StatPanel(label: "SUCCESS RATE", value: "\(detailedStats.successRate)%", color: .green, accentColor: accentColor)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatPanelMini(label: "AVG", value: String(format: "%.1f", detailedStats.averageRoll), color: accentColor)
                StatPanelMini(label: "CRITS", value: "\(detailedStats.criticals)", color: .green)
                StatPanelMini(label: "FUMBLES", value: "\(detailedStats.fumbles)", color: .red)
            }
        }
    }
    
    private var distributionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("ROLL DISTRIBUTION")
            
            if #available(iOS 16.0, *) {
                Chart(detailedStats.distribution) { item in
                    BarMark(
                        x: .value("Result", item.result),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel().font(.custom("PlayfairDisplay-Regular", size: 10)).foregroundStyle(.white.opacity(0.5))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel().font(.custom("PlayfairDisplay-Regular", size: 10)).foregroundStyle(.white.opacity(0.5))
                    }
                }
            } else {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(detailedStats.distribution) { item in
                        VStack {
                            Rectangle()
                                .fill(accentColor)
                                .frame(width: 14, height: max(4, CGFloat(item.count) * 10))
                                .cornerRadius(2)
                            Text("\(item.result)")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private var dicePerformanceSection: some View {
        VStack(spacing: 16) {
            ForEach(detailedStats.dicePerformance, id: \.diceName) { perf in
                VStack(spacing: 8) {
                    HStack {
                        Text(perf.diceName)
                            .font(.custom("PlayfairDisplay-Black", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                        Text("AVG \(perf.average, specifier: "%.1f") • \(perf.count) ROLLS")
                            .font(.custom("PlayfairDisplay-Bold", size: 10))
                            .foregroundColor(accentColor.opacity(0.8))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [accentColor, accentColor.opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(perf.successRate / 100), height: 6)
                                .shadow(color: accentColor.opacity(0.3), radius: 4)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(16)
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
            }
        }
    }
    
    private var timeAnalysisSection: some View {
        HStack(spacing: 16) {
            AnalysisCard(
                label: "PEAK HOUR", 
                value: "\(detailedStats.mostActiveHour):00", 
                icon: "clock.fill", 
                accentColor: accentColor
            )
            AnalysisCard(
                label: "AVG ROLLS/DAY", 
                value: String(format: "%.1f", detailedStats.averageRollsPerDay), 
                icon: "calendar", 
                accentColor: accentColor
            )
        }
    }
    
    private var streaksSection: some View {
        HStack(spacing: 16) {
            AnalysisCard(
                label: "BEST STREAK", 
                value: "\(detailedStats.longestSuccessStreak)", 
                icon: "flame.fill", 
                accentColor: .green
            )
            AnalysisCard(
                label: "WORST STREAK", 
                value: "\(detailedStats.longestFailureStreak)", 
                icon: "snowflake", 
                accentColor: .red
            )
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles.square.filled.on.square")
                .font(.system(size: 60))
                .foregroundColor(accentColor.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No Omens Found")
                    .font(.custom("PlayfairDisplay-Bold", size: 24))
                    .foregroundColor(.white)
                Text("Change your filters to reveal the truth.")
                    .font(.custom("PlayfairDisplay-Regular", size: 16))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(.top, 100)
    }
}

// MARK: - Components

struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom("PlayfairDisplay-Bold", size: 10))
                .foregroundColor(isSelected ? .black : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? accentColor : Color.white.opacity(0.05))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct StatPanel: View {
    let label: String
    let value: String
    let color: Color
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.custom("PlayfairDisplay-Bold", size: 10))
                .foregroundColor(accentColor.opacity(0.7))
                .tracking(2)
            
            Text(value)
                .font(.custom("PlayfairDisplay-Black", size: 32))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.3), radius: 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct StatPanelMini: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.custom("PlayfairDisplay-Bold", size: 9))
                .foregroundColor(.white.opacity(0.5))
            
            Text(value)
                .font(.custom("PlayfairDisplay-Black", size: 18))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct AnalysisCard: View {
    let label: String
    let value: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor.opacity(0.8))
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.custom("PlayfairDisplay-Black", size: 24))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.custom("PlayfairDisplay-Bold", size: 9))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
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
