//
//  DiceComplication.swift
//  DnDiceWatchApp Watch App
//
//  Complications for Apple Watch Face
//  Shows last dice roll result directly on watch face
//

import SwiftUI
import WidgetKit

// MARK: - Widget Configuration
struct DiceComplication: Widget {
    let kind: String = "DiceComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiceComplicationProvider()) { entry in
            DiceComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("Last Dice Roll")
        .description("Shows your most recent dice roll result")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

// MARK: - Timeline Provider
struct DiceComplicationProvider: TimelineProvider {
    typealias Entry = DiceComplicationEntry
    
    private let appGroup = "group.com.DalPra.DiceAndDragons"
    
    func placeholder(in context: Context) -> DiceComplicationEntry {
        DiceComplicationEntry(date: Date(), result: 20, diceType: "D20", isCritical: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DiceComplicationEntry) -> Void) {
        let entry = getCurrentEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DiceComplicationEntry>) -> Void) {
        let entry = getCurrentEntry()
        
        // Update every 15 minutes (watchOS limitation)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func getCurrentEntry() -> DiceComplicationEntry {
        guard let sharedDefaults = UserDefaults(suiteName: appGroup) else {
            return DiceComplicationEntry(date: Date(), result: 20, diceType: "D20", isCritical: false)
        }
        
        let result = sharedDefaults.integer(forKey: "lastDiceResult")
        let diceType = sharedDefaults.string(forKey: "lastDiceType") ?? "D20"
        let date = sharedDefaults.object(forKey: "lastRollDate") as? Date ?? Date()
        
        // Determine if critical based on dice type
        let isCritical: Bool
        if diceType == "D20" {
            isCritical = result == 20
        } else if diceType == "D12" {
            isCritical = result == 12
        } else if diceType == "D10" {
            isCritical = result == 10
        } else if diceType == "D8" {
            isCritical = result == 8
        } else if diceType == "D6" {
            isCritical = result == 6
        } else if diceType == "D4" {
            isCritical = result == 4
        } else {
            isCritical = false
        }
        
        return DiceComplicationEntry(
            date: date,
            result: result > 0 ? result : 20,
            diceType: diceType,
            isCritical: isCritical
        )
    }
}

// MARK: - Timeline Entry
struct DiceComplicationEntry: TimelineEntry {
    let date: Date
    let result: Int
    let diceType: String
    let isCritical: Bool
}

// MARK: - Complication Views
struct DiceComplicationEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: DiceComplicationProvider.Entry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularComplicationView(entry: entry)
        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)
        case .accessoryInline:
            InlineComplicationView(entry: entry)
        case .accessoryCorner:
            CornerComplicationView(entry: entry)
        default:
            CircularComplicationView(entry: entry)
        }
    }
}

// MARK: - Circular Complication (most common)
struct CircularComplicationView: View {
    let entry: DiceComplicationEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 2) {
                Text("\(entry.result)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(entry.isCritical ? .green : .white)
                
                Text(entry.diceType)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Rectangular Complication
struct RectangularComplicationView: View {
    let entry: DiceComplicationEntry
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.isCritical ? "star.fill" : "dice.fill")
                .font(.title2)
                .foregroundColor(entry.isCritical ? .green : .accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.result)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(entry.isCritical ? .green : .white)
                
                Text(entry.diceType)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Inline Complication
struct InlineComplicationView: View {
    let entry: DiceComplicationEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "dice.fill")
            Text("\(entry.diceType): \(entry.result)")
                .font(.system(.caption, design: .rounded))
        }
    }
}

// MARK: - Corner Complication
struct CornerComplicationView: View {
    let entry: DiceComplicationEntry
    
    var body: some View {
        Text("\(entry.result)")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(entry.isCritical ? .green : .white)
            .widgetLabel {
                Text(entry.diceType)
                    .font(.caption2)
            }
    }
}

#Preview("Circular", as: .accessoryCircular) {
    DiceComplication()
} timeline: {
    DiceComplicationEntry(date: Date(), result: 20, diceType: "D20", isCritical: true)
    DiceComplicationEntry(date: Date(), result: 7, diceType: "D12", isCritical: false)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    DiceComplication()
} timeline: {
    DiceComplicationEntry(date: Date(), result: 20, diceType: "D20", isCritical: true)
}
