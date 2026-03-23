
import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Constants & Provider
private enum WidgetConstants {
    static let appGroup = "group.com.DalPra.DiceAndDragons"
    enum Keys {
        static let lastResult = "lastDiceResult"
        static let lastType = "lastDiceType"
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DiceEntry {
        DiceEntry(date: Date(), result: 20, type: "D20")
    }

    func getSnapshot(in context: Context, completion: @escaping (DiceEntry) -> ()) {
        completion(fetchData())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = fetchData()
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
    
    private func fetchData() -> DiceEntry {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroup)
        let res = defaults?.integer(forKey: WidgetConstants.Keys.lastResult) ?? 0
        let type = defaults?.string(forKey: WidgetConstants.Keys.lastType) ?? "D20"
        return DiceEntry(date: Date(), result: res, type: type)
    }
}

struct DiceEntry: TimelineEntry {
    let date: Date
    let result: Int
    let type: String
    
    var isCrit: Bool {
        let sides = Int(type.replacingOccurrences(of: "D", with: "")) ?? 20
        return result == sides
    }
    var isFumble: Bool { result == 1 && result != 0 }
}

// MARK: - Components

struct WidgetActionButton: View {
    let type: DiceTypeEntity
    let icon: String?
    let label: String
    
    var body: some View {
        Button(intent: RollDiceIntent(diceType: type)) {
            VStack(spacing: 2) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(label)
                    .font(.custom("PlayfairDisplay-Bold", size: 12))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WidgetDesignSystem.Colors.gold)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Views

struct SmallWidgetView: View {
    let entry: DiceEntry
    
    var body: some View {
        Button(intent: RollDiceIntent(diceType: .d20)) {
            VStack(spacing: 0) {
                Text(entry.type)
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(WidgetDesignSystem.Colors.gold.opacity(0.8))
                
                Spacer(minLength: 0)
                
                Text("\(entry.result == 0 ? "?" : "\(entry.result)")")
                    .font(.custom("PlayfairDisplay-Black", size: 64))
                    .foregroundColor(WidgetDesignSystem.Colors.resultColor(isCrit: entry.isCrit, isFumble: entry.isFumble))
                    .shadow(color: WidgetDesignSystem.Colors.resultColor(isCrit: entry.isCrit, isFumble: entry.isFumble).opacity(0.3), radius: 10)
                
                Spacer(minLength: 0)
                
                Text("TAP TO ROLL")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(WidgetDesignSystem.Colors.gold.opacity(0.4))
                    .tracking(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct MediumWidgetView: View {
    let entry: DiceEntry
    
    var body: some View {
        HStack(spacing: 20) {
            // Left: Display
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.type)
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
                    .foregroundColor(WidgetDesignSystem.Colors.gold)
                
                Text("\(entry.result)")
                    .font(.custom("PlayfairDisplay-Black", size: 72))
                    .foregroundColor(WidgetDesignSystem.Colors.resultColor(isCrit: entry.isCrit, isFumble: entry.isFumble))
                    .minimumScaleFactor(0.5)
                
                if entry.isCrit {
                    Text("CRITICAL HIT")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.green)
                } else if entry.isFumble {
                    Text("FUMBLE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right: Grid
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    WidgetActionButton(type: .d4, icon: nil, label: "D4")
                    WidgetActionButton(type: .d6, icon: nil, label: "D6")
                    WidgetActionButton(type: .d8, icon: nil, label: "D8")
                }
                HStack(spacing: 8) {
                    WidgetActionButton(type: .d10, icon: nil, label: "D10")
                    WidgetActionButton(type: .d12, icon: nil, label: "D12")
                    WidgetActionButton(type: .d20, icon: "hexagon.fill", label: "D20")
                }
            }
            .frame(width: 150)
        }
        .padding(16)
    }
}

struct LargeWidgetView: View {
    let entry: DiceEntry
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LATEST ROLL")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.secondary)
                    Text(entry.type)
                        .font(.custom("PlayfairDisplay-Bold", size: 28))
                        .foregroundColor(WidgetDesignSystem.Colors.gold)
                }
                Spacer()
                Text("\(entry.result)")
                    .font(.custom("PlayfairDisplay-Black", size: 96))
                    .foregroundColor(WidgetDesignSystem.Colors.resultColor(isCrit: entry.isCrit, isFumble: entry.isFumble))
            }
            
            Divider().background(WidgetDesignSystem.Colors.gold.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("QUICK ACTION TRAY")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.secondary)
                    .tracking(1)
                
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        WidgetActionButton(type: .d4, icon: nil, label: "D4")
                        WidgetActionButton(type: .d6, icon: nil, label: "D6")
                        WidgetActionButton(type: .d8, icon: nil, label: "D8")
                    }
                    GridRow {
                        WidgetActionButton(type: .d10, icon: nil, label: "D10")
                        WidgetActionButton(type: .d12, icon: nil, label: "D12")
                        WidgetActionButton(type: .d20, icon: "hexagon.fill", label: "D20")
                    }
                }
            }
            
            Spacer()
        }
        .padding(24)
    }
}

// MARK: - Entry Point
struct DnDiceWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall: SmallWidgetView(entry: entry)
            case .systemMedium: MediumWidgetView(entry: entry)
            case .systemLarge: LargeWidgetView(entry: entry)
            default: SmallWidgetView(entry: entry)
            }
        }
    }
}

struct DnDiceWidget: Widget {
    let kind: String = "DnDiceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DnDiceWidgetEntryView(entry: entry)
                .containerBackground(Color.black, for: .widget)
        }
        .configurationDisplayName("D&D Master Tray")
        .description("Quickly roll any die directly from your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
