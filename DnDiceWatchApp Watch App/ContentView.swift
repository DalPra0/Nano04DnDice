//
//  ContentView.swift
//  DnDiceWatchApp Watch App
//
//  Created by Lucas Dal Pra Brascher on 04/12/25.
//

import SwiftUI
import WatchKit
import Combine

// MARK: - Main Roll View (Apple HIG Compliant)
struct ContentView: View {
    @StateObject private var viewModel = WatchDiceViewModel.shared
    @State private var isAnimating = false
    @State private var crownValue: Double = 2 // Index for Digital Crown (0-5 for 6 dice types)
    @Environment(\.isLuminanceReduced) var isLuminanceReduced // Always-On Display
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    // Dice Type Selector with Digital Crown
                    DiceTypePickerView(
                        selectedDice: $viewModel.selectedDice,
                        crownValue: $crownValue,
                        geometry: geometry
                    )
                    
                    // Result Display (responsive)
                    if let result = viewModel.lastResult {
                        DiceResultView(
                            result: result,
                            diceType: viewModel.selectedDice,
                            isAnimating: isAnimating,
                            isAOD: isLuminanceReduced,
                            geometry: geometry
                        )
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        PlaceholderView(geometry: geometry, isAOD: isLuminanceReduced)
                    }
                    
                    // Roll Button (minimum touch target 44pt)
                    RollButtonView(isRolling: $viewModel.isRolling) {
                        rollDice()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16) // Apple HIG: 16pt horizontal padding
                .padding(.vertical, 12)    // Apple HIG: 12pt vertical padding
            }
        }
        .navigationTitle(viewModel.selectedDice.name)
        .navigationBarTitleDisplayMode(.inline)
        // Digital Crown support for dice selection
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: Double(WatchDiceType.allCases.count - 1),
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            let index = Int(newValue.rounded())
            if index >= 0 && index < WatchDiceType.allCases.count {
                viewModel.selectedDice = WatchDiceType.allCases[index]
                WKInterfaceDevice.current().play(.click)
            }
        }
    }
    
    private func rollDice() {
        isAnimating = true
        viewModel.roll()
        
        // Haptic feedback (success pattern)
        WKInterfaceDevice.current().play(.success)
        
        // Quick animation (watchOS best practice: <0.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isAnimating = false
        }
    }
}

// MARK: - Dice Type Picker (Digital Crown Compatible)

struct DiceTypePickerView: View {
    @Binding var selectedDice: WatchDiceType
    @Binding var crownValue: Double
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Select Dice")
                .font(.footnote) // 13pt (accessible minimum)
                .foregroundColor(.secondary)
            
            // Digital Crown indicator
            HStack(spacing: 4) {
                Image(systemName: "digitalcrown.horizontal.fill")
                    .font(.caption)
                Text("Rotate crown to change")
                    .font(.caption) // 12pt minimum
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 4)
            
            // Dice type selector (scrollable horizontally)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(WatchDiceType.allCases) { dice in
                        Button(action: {
                            selectedDice = dice
                            crownValue = Double(WatchDiceType.allCases.firstIndex(of: dice) ?? 0)
                            WKInterfaceDevice.current().play(.click)
                        }) {
                            Text(dice.name)
                                .font(.footnote) // 13pt (was caption2 11pt)
                                .fontWeight(selectedDice == dice ? .bold : .regular)
                                .foregroundColor(selectedDice == dice ? .white : .secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .frame(minWidth: 44, minHeight: 32) // Minimum touch target
                                .background(
                                    Capsule()
                                        .fill(selectedDice == dice ? Color.accentColor : Color.clear)
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Dice Result View (Responsive + AOD)

struct DiceResultView: View {
    let result: Int
    let diceType: WatchDiceType
    let isAnimating: Bool
    let isAOD: Bool
    let geometry: GeometryProxy
    
    var isCritical: Bool {
        result == diceType.sides
    }
    
    var isFumble: Bool {
        result == 1
    }
    
    var resultColor: Color {
        if isAOD { return .white } // Always-On Display: simplified colors
        if isCritical { return .green }
        if isFumble { return .red }
        return .accentColor
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Responsive circle size (40mm: 80pt, 45mm: 90pt, 49mm: 100pt)
                let circleSize = min(geometry.size.width * 0.45, 100)
                
                // Background (hidden in AOD to save power)
                if !isAOD {
                    Circle()
                        .fill(resultColor.opacity(0.15))
                        .frame(width: circleSize, height: circleSize)
                }
                
                Circle()
                    .strokeBorder(resultColor, lineWidth: isAOD ? 2 : 3)
                    .frame(width: circleSize, height: circleSize)
                
                VStack(spacing: 4) {
                    Text("\(result)")
                        .font(.system(size: circleSize * 0.4, weight: .bold, design: .rounded))
                        .foregroundColor(resultColor)
                    
                    if !isAOD && (isCritical || isFumble) {
                        Text(isCritical ? "CRIT!" : "FUMBLE!")
                            .font(.caption) // 12pt (was caption2 11pt)
                            .fontWeight(.bold)
                            .foregroundColor(resultColor)
                    }
                }
            }
            .scaleEffect(isAnimating ? 1.15 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isAnimating)
            
            if !isAOD {
                Text(diceType.name)
                    .font(.footnote) // 13pt (was caption 12pt)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Placeholder View (Responsive)

struct PlaceholderView: View {
    let geometry: GeometryProxy
    let isAOD: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                let circleSize = min(geometry.size.width * 0.45, 100)
                
                if !isAOD {
                    Circle()
                        .fill(Color.secondary.opacity(0.1))
                        .frame(width: circleSize, height: circleSize)
                }
                
                Image(systemName: "dice.fill")
                    .font(.system(size: circleSize * 0.35))
                    .foregroundColor(.secondary)
            }
            
            if !isAOD {
                Text("Roll to start")
                    .font(.footnote) // 13pt (was caption 12pt)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Roll Button (44pt minimum touch target)

struct RollButtonView: View {
    @Binding var isRolling: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            guard !isRolling else { return }
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "dice.fill")
                Text("ROLL")
                    .fontWeight(.bold)
            }
            .font(.body) // 17pt (was headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // Apple HIG: minimum touch target
            .background(
                Capsule()
                    .fill(isRolling ? Color.secondary : Color.accentColor)
            )
        }
        .buttonStyle(.plain)
        .disabled(isRolling)
    }
}

// MARK: - View Model (Syncs with iPhone via App Group)

class WatchDiceViewModel: ObservableObject {
    static let shared = WatchDiceViewModel()
    
    @Published var selectedDice: WatchDiceType = .d20
    @Published var lastResult: Int?
    @Published var isRolling = false
    @Published var rollHistory: [WatchRollRecord] = []
    
    private let historyKey = "watchRollHistory"
    private let appGroup = "group.com.DalPra.DiceAndDragons" // Sync with iPhone
    
    private init() {
        loadHistory()
        syncWithIPhone()
    }
    
    func roll() {
        isRolling = true
        
        // Quick roll (watchOS best practice: instant feedback)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            let result = Int.random(in: 1...self.selectedDice.sides)
            self.lastResult = result
            
            // Save to history
            let record = WatchRollRecord(
                dice: self.selectedDice,
                result: result,
                date: Date()
            )
            self.rollHistory.insert(record, at: 0)
            if self.rollHistory.count > 50 {
                self.rollHistory.removeLast()
            }
            self.saveHistory()
            self.syncWithIPhone()
            
            self.isRolling = false
        }
    }
    
    private func loadHistory() {
        // Try loading from App Group first (shared with iPhone)
        if let sharedDefaults = UserDefaults(suiteName: appGroup),
           let data = sharedDefaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([WatchRollRecord].self, from: data) {
            rollHistory = decoded
        } else if let data = UserDefaults.standard.data(forKey: historyKey),
                  let decoded = try? JSONDecoder().decode([WatchRollRecord].self, from: data) {
            rollHistory = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(rollHistory) {
            // Save to both local and App Group
            UserDefaults.standard.set(encoded, forKey: historyKey)
            UserDefaults(suiteName: appGroup)?.set(encoded, forKey: historyKey)
        }
    }
    
    private func syncWithIPhone() {
        // Sync last result with iPhone for Widget/Complications
        guard let lastResult = lastResult else { return }
        
        if let sharedDefaults = UserDefaults(suiteName: appGroup) {
            sharedDefaults.set(lastResult, forKey: "lastDiceResult")
            sharedDefaults.set(selectedDice.name, forKey: "lastDiceType")
            sharedDefaults.set(Date(), forKey: "lastRollDate")
        }
    }
}

// MARK: - Models

enum WatchDiceType: String, Codable, CaseIterable, Identifiable {
    case d4, d6, d8, d10, d12, d20
    
    var id: String { rawValue }
    
    var name: String {
        rawValue.uppercased()
    }
    
    var sides: Int {
        switch self {
        case .d4: return 4
        case .d6: return 6
        case .d8: return 8
        case .d10: return 10
        case .d12: return 12
        case .d20: return 20
        }
    }
    
    /// SF Symbol number for die.face icons (1-6)
    var iconNumber: Int {
        switch self {
        case .d4: return 1
        case .d6: return 2
        case .d8: return 3
        case .d10: return 4
        case .d12: return 5
        case .d20: return 6
        }
    }
}

struct WatchRollRecord: Codable, Identifiable {
    let id: UUID
    let dice: WatchDiceType
    let result: Int
    let date: Date
    
    init(id: UUID = UUID(), dice: WatchDiceType, result: Int, date: Date) {
        self.id = id
        self.dice = dice
        self.result = result
        self.date = date
    }
}

#Preview {
    ContentView()
}
