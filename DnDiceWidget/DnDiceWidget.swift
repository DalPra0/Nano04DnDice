//
//  DnDiceWidget.swift
//  DnDiceWidget
//
//  Created by Lucas Dal Pra Brascher on 10/10/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DiceEntry {
        DiceEntry(date: Date(), result: 20, diceType: "D20", isCritical: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (DiceEntry) -> ()) {
        let entry = getCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getCurrentEntry()
        
        // Update when app rolls (not time-based)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func getCurrentEntry() -> DiceEntry {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroup)
        let lastResult = sharedDefaults?.integer(forKey: AppConstants.UserDefaultsKeys.lastDiceResult) ?? 20
        let lastDiceType = sharedDefaults?.string(forKey: AppConstants.UserDefaultsKeys.lastDiceType) ?? "D20"
        let lastRollDate = sharedDefaults?.object(forKey: AppConstants.UserDefaultsKeys.lastRollDate) as? Date ?? Date()
        
        let maxSides = Int(lastDiceType.dropFirst()) ?? 20
        let isCritical = lastResult == maxSides
        let isFumble = lastResult == 1
        
        return DiceEntry(
            date: lastRollDate,
            result: lastResult,
            diceType: lastDiceType,
            isCritical: isCritical,
            isFumble: isFumble
        )
    }
}

// MARK: - Timeline Entry
struct DiceEntry: TimelineEntry {
    let date: Date
    let result: Int
    let diceType: String
    let isCritical: Bool
    var isFumble: Bool = false
}

// MARK: - Widget Entry View (Router)
struct DnDiceWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry, colorScheme: colorScheme)
        case .systemMedium:
            MediumWidgetView(entry: entry, colorScheme: colorScheme)
        case .systemLarge:
            LargeWidgetView(entry: entry, colorScheme: colorScheme)
        case .accessoryCircular:
            CircularAccessoryView(entry: entry)
        case .accessoryRectangular:
            RectangularAccessoryView(entry: entry)
        case .accessoryInline:
            InlineAccessoryView(entry: entry)
        default:
            SmallWidgetView(entry: entry, colorScheme: colorScheme)
        }
    }
}

// MARK: - Small Widget (Clean & Minimal)
struct SmallWidgetView: View {
    let entry: DiceEntry
    let colorScheme: ColorScheme
    
    var resultColor: Color {
        if entry.isCritical { return WidgetDesignSystem.Colors.critical }
        if entry.isFumble { return WidgetDesignSystem.Colors.fumble }
        return WidgetDesignSystem.Colors.brandGold
    }
    
    var body: some View {
        ZStack {
            WidgetDesignSystem.Colors.adaptiveGradient(colorScheme: colorScheme)
            
            VStack(spacing: WidgetDesignSystem.Spacing.sm) {
                // Dice type
                Text(entry.diceType)
                    .font(WidgetDesignSystem.Typography.diceType)
                    .foregroundColor(WidgetDesignSystem.Colors.brandGold.opacity(0.8))
                
                // Result (responsive to widget size)
                Text("\(entry.result)")
                    .font(WidgetDesignSystem.Typography.resultSmall)
                    .foregroundColor(resultColor)
                    .shadow(color: resultColor.opacity(0.3), radius: 8)
                
                // Critical/Fumble indicator
                if entry.isCritical {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("CRIT")
                            .font(WidgetDesignSystem.Typography.critical)
                    }
                    .foregroundColor(WidgetDesignSystem.Colors.critical)
                } else if entry.isFumble {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                        Text("FUMBLE")
                            .font(WidgetDesignSystem.Typography.critical)
                    }
                    .foregroundColor(WidgetDesignSystem.Colors.fumble)
                }
            }
            .padding(WidgetDesignSystem.Spacing.md)
        }
    }
}

// MARK: - Medium Widget (Interactive with Button)
struct MediumWidgetView: View {
    let entry: DiceEntry
    let colorScheme: ColorScheme
    
    var resultColor: Color {
        if entry.isCritical { return WidgetDesignSystem.Colors.critical }
        if entry.isFumble { return WidgetDesignSystem.Colors.fumble }
        return WidgetDesignSystem.Colors.brandGold
    }
    
    var body: some View {
        ZStack {
            WidgetDesignSystem.Colors.adaptiveGradient(colorScheme: colorScheme)
            
            HStack(spacing: WidgetDesignSystem.Spacing.lg) {
                // Left: Result display
                VStack(alignment: .leading, spacing: WidgetDesignSystem.Spacing.sm) {
                    Text(entry.diceType)
                        .font(WidgetDesignSystem.Typography.title)
                        .foregroundColor(WidgetDesignSystem.Colors.brandGold)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(entry.result)")
                            .font(WidgetDesignSystem.Typography.resultMedium)
                            .foregroundColor(resultColor)
                        
                        if entry.isCritical {
                            Image(systemName: "star.fill")
                                .font(.title3)
                                .foregroundColor(WidgetDesignSystem.Colors.critical)
                        } else if entry.isFumble {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title3)
                                .foregroundColor(WidgetDesignSystem.Colors.fumble)
                        }
                    }
                    
                    Text(timeAgoString(from: entry.date))
                        .font(WidgetDesignSystem.Typography.caption)
                        .foregroundColor(WidgetDesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Right: Interactive button (iOS 17+)
                if #available(iOS 17.0, *) {
                    VStack(spacing: WidgetDesignSystem.Spacing.sm) {
                        Button(intent: RollDiceIntent(diceType: .d20)) {
                            VStack(spacing: 4) {
                                Image(systemName: "dice.fill")
                                    .font(.title2)
                                Text("Roll\nD20")
                                    .font(WidgetDesignSystem.Typography.caption)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(WidgetDesignSystem.Colors.brandGold)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Image(systemName: "dice.fill")
                        .font(.system(size: 40))
                        .foregroundColor(WidgetDesignSystem.Colors.brandGold.opacity(0.3))
                }
            }
            .padding(WidgetDesignSystem.Spacing.lg)
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let minutes = Int(Date().timeIntervalSince(date) / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
    }
}

struct LargeWidgetView: View {
    let entry: DiceEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1a1a2e"),
                    Color(hex: "#16213e")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("D&D DICE ROLLER")
                            .font(.custom("PlayfairDisplay-Bold", size: 16))
                            .foregroundColor(Color(hex: "#FFD700"))
                            .tracking(3)
                        
                        Text("Last Roll Result")
                            .font(.custom("PlayfairDisplay-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "dice.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#FFD700").opacity(0.3))
                }
                
                // Main result
                VStack(spacing: 12) {
                    Text(entry.diceType)
                        .font(.custom("PlayfairDisplay-Bold", size: 24))
                        .foregroundColor(Color(hex: "#FFD700").opacity(0.8))
                    
                    Text("\(entry.result)")
                        .font(.custom("PlayfairDisplay-Black", size: 120))
                        .foregroundColor(entry.isCritical ? .green : Color(hex: "#FFD700"))
                        .shadow(color: entry.isCritical ? .green.opacity(0.5) : Color(hex: "#FFD700").opacity(0.3), radius: 20)
                    
                    if entry.isCritical {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.green)
                            Text("CRITICAL HIT!")
                                .font(.custom("PlayfairDisplay-Bold", size: 18))
                                .foregroundColor(.green)
                                .tracking(3)
                            Image(systemName: "star.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Footer
                HStack {
                    Text(timeAgoString(from: entry.date))
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text("Tap to roll again")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(Color(hex: "#FFD700").opacity(0.6))
                }
            }
            .padding()
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let minutes = Int(Date().timeIntervalSince(date) / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes) minutes ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours) hours ago" }
        let days = hours / 24
        return "\(days) days ago"
    }
}

struct StatBadge: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(label)
                .font(.custom("PlayfairDisplay-Regular", size: 12))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
        )
    }
}

struct DnDiceWidget: Widget {
    let kind: String = "DnDiceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DnDiceWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DnDiceWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("D&D Dice")
        .description("Show your last dice roll result")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview(as: .systemSmall) {
    DnDiceWidget()
} timeline: {
    DiceEntry(date: .now, result: 20, diceType: "D20", isCritical: true)
    DiceEntry(date: .now, result: 15, diceType: "D20", isCritical: false)
}

