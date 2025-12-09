//
//  DnDiceWidget.swift
//  DnDiceWidget
//
//  Created by Lucas Dal Pra Brascher on 10/10/25.
//

import WidgetKit
import SwiftUI
import AppIntents

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

// MARK: - Large Widget (Interactive with Multiple Buttons)
struct LargeWidgetView: View {
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
            
            VStack(spacing: WidgetDesignSystem.Spacing.lg) {
                // Result display
                VStack(spacing: WidgetDesignSystem.Spacing.sm) {
                    Text(entry.diceType)
                        .font(WidgetDesignSystem.Typography.title)
                        .foregroundColor(WidgetDesignSystem.Colors.brandGold)
                    
                    Text("\(entry.result)")
                        .font(WidgetDesignSystem.Typography.resultLarge)
                        .foregroundColor(resultColor)
                        .shadow(color: resultColor.opacity(0.3), radius: 12)
                    
                    if entry.isCritical {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                            Text("CRITICAL HIT!")
                                .font(WidgetDesignSystem.Typography.subtitle)
                            Image(systemName: "star.fill")
                        }
                        .foregroundColor(WidgetDesignSystem.Colors.critical)
                    } else if entry.isFumble {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("FUMBLE!")
                                .font(WidgetDesignSystem.Typography.subtitle)
                        }
                        .foregroundColor(WidgetDesignSystem.Colors.fumble)
                    }
                }
                
                Spacer()
                
                // Interactive buttons (iOS 17+)
                if #available(iOS 17.0, *) {
                    VStack(spacing: WidgetDesignSystem.Spacing.md) {
                        Text("Quick Roll")
                            .font(WidgetDesignSystem.Typography.caption)
                            .foregroundColor(WidgetDesignSystem.Colors.textSecondary)
                        
                        HStack(spacing: WidgetDesignSystem.Spacing.sm) {
                            DiceButton(diceType: .d4)
                            DiceButton(diceType: .d6)
                            DiceButton(diceType: .d8)
                            DiceButton(diceType: .d12)
                            DiceButton(diceType: .d20)
                        }
                    }
                } else {
                    Text(timeAgoString(from: entry.date))
                        .font(WidgetDesignSystem.Typography.caption)
                        .foregroundColor(WidgetDesignSystem.Colors.textSecondary)
                }
            }
            .padding(WidgetDesignSystem.Spacing.lg)
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let minutes = Int(Date().timeIntervalSince(date) / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes) min ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours) hours ago" }
        let days = hours / 24
        return "\(days) days ago"
    }
}

// MARK: - Dice Button Component (iOS 17+)
@available(iOS 17.0, *)
struct DiceButton: View {
    let diceType: DiceTypeEntity
    
    var body: some View {
        Button(intent: RollDiceIntent(diceType: diceType)) {
            Text(diceType.rawValue)
                .font(WidgetDesignSystem.Typography.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(WidgetDesignSystem.Colors.brandGold)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lock Screen Widgets (iOS 16+)

// Circular Accessory (Lock Screen circular complication)
struct CircularAccessoryView: View {
    let entry: DiceEntry
    
    var resultColor: Color {
        if entry.isCritical { return .green }
        if entry.isFumble { return .red }
        return .white
    }
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 2) {
                Text("\(entry.result)")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(resultColor)
                
                Text(entry.diceType)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Rectangular Accessory (Lock Screen rectangular complication)
struct RectangularAccessoryView: View {
    let entry: DiceEntry
    
    var resultColor: Color {
        if entry.isCritical { return .green }
        if entry.isFumble { return .red }
        return .white
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Image(systemName: entry.isCritical ? "star.fill" : entry.isFumble ? "exclamationmark.triangle.fill" : "dice.fill")
                .font(.title3)
                .foregroundColor(resultColor)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.result)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(resultColor)
                
                Text(entry.diceType)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

// Inline Accessory (Lock Screen inline text)
struct InlineAccessoryView: View {
    let entry: DiceEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "dice.fill")
            Text("\(entry.diceType): \(entry.result)")
                .font(.system(.caption, design: .rounded))
            if entry.isCritical {
                Image(systemName: "star.fill")
            }
        }
    }
}

// MARK: - Widget Configuration
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
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Previews
#Preview("Small", as: .systemSmall) {
    DnDiceWidget()
} timeline: {
    DiceEntry(date: .now, result: 20, diceType: "D20", isCritical: true, isFumble: false)
    DiceEntry(date: .now, result: 1, diceType: "D20", isCritical: false, isFumble: true)
    DiceEntry(date: .now, result: 15, diceType: "D20", isCritical: false, isFumble: false)
}

#Preview("Medium", as: .systemMedium) {
    DnDiceWidget()
} timeline: {
    DiceEntry(date: .now, result: 20, diceType: "D20", isCritical: true, isFumble: false)
}

#Preview("Circular", as: .accessoryCircular) {
    DnDiceWidget()
} timeline: {
    DiceEntry(date: .now, result: 20, diceType: "D20", isCritical: true, isFumble: false)
}

