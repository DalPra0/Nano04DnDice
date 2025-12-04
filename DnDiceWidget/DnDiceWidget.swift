//
//  DnDiceWidget.swift
//  DnDiceWidget
//
//  Created by Lucas Dal Pra Brascher on 10/10/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DiceEntry {
        DiceEntry(date: Date(), result: 20, diceType: "D20", isCritical: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (DiceEntry) -> ()) {
        let entry = DiceEntry(date: Date(), result: 20, diceType: "D20", isCritical: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get last roll from UserDefaults (shared with main app)
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.Nano04DnDice")
        let lastResult = sharedDefaults?.integer(forKey: "lastDiceResult") ?? 20
        let lastDiceType = sharedDefaults?.string(forKey: "lastDiceType") ?? "D20"
        let lastRollDate = sharedDefaults?.object(forKey: "lastRollDate") as? Date ?? Date()
        
        let maxSides = Int(lastDiceType.dropFirst()) ?? 20
        let isCritical = lastResult == maxSides
        
        let entry = DiceEntry(
            date: lastRollDate,
            result: lastResult,
            diceType: lastDiceType,
            isCritical: isCritical
        )
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct DiceEntry: TimelineEntry {
    let date: Date
    let result: Int
    let diceType: String
    let isCritical: Bool
}

struct DnDiceWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
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
            
            VStack(spacing: 8) {
                Text(entry.diceType)
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(Color(hex: "#FFD700").opacity(0.8))
                
                Text("\(entry.result)")
                    .font(.custom("PlayfairDisplay-Black", size: 52))
                    .foregroundColor(entry.isCritical ? .green : Color(hex: "#FFD700"))
                    .shadow(color: entry.isCritical ? .green.opacity(0.5) : Color(hex: "#FFD700").opacity(0.3), radius: 10)
                
                if entry.isCritical {
                    Text("CRITICAL!")
                        .font(.custom("PlayfairDisplay-Bold", size: 10))
                        .foregroundColor(.green)
                        .tracking(2)
                }
            }
            .padding()
        }
    }
}

struct MediumWidgetView: View {
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
            
            HStack(spacing: 20) {
                // Left side - Dice result
                VStack(alignment: .leading, spacing: 8) {
                    Text("LAST ROLL")
                        .font(.custom("PlayfairDisplay-Bold", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(2)
                    
                    Text(entry.diceType)
                        .font(.custom("PlayfairDisplay-Bold", size: 18))
                        .foregroundColor(Color(hex: "#FFD700"))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(entry.result)")
                            .font(.custom("PlayfairDisplay-Black", size: 72))
                            .foregroundColor(entry.isCritical ? .green : Color(hex: "#FFD700"))
                        
                        if entry.isCritical {
                            VStack(alignment: .leading, spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.green)
                                Text("CRIT")
                                    .font(.custom("PlayfairDisplay-Bold", size: 10))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Right side - Quick stats
                VStack(alignment: .trailing, spacing: 12) {
                    StatBadge(
                        icon: "clock.arrow.circlepath",
                        label: "Recent",
                        color: Color(hex: "#FFD700")
                    )
                    
                    Text(timeAgoString(from: entry.date))
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding()
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

