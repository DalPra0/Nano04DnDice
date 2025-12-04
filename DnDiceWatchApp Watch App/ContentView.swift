//
//  ContentView.swift
//  DnDiceWatchApp Watch App
//
//  Created by Lucas Dal Pra Brascher on 04/12/25.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var viewModel = WatchDiceViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // Dice Type Selector
                DiceTypePickerView(selectedDice: $viewModel.selectedDice)
                
                // Result Display
                if let result = viewModel.lastResult {
                    DiceResultView(
                        result: result,
                        diceType: viewModel.selectedDice,
                        isAnimating: isAnimating
                    )
                    .transition(.scale.combined(with: .opacity))
                } else {
                    PlaceholderView()
                }
                
                // Roll Button
                RollButtonView(isRolling: $viewModel.isRolling) {
                    rollDice()
                }
            }
            .padding(.vertical, 8)
            .navigationTitle("D&D Dice")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func rollDice() {
        isAnimating = true
        viewModel.roll()
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.notification)
        
        // Animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = false
        }
    }
}

// MARK: - Dice Type Picker

struct DiceTypePickerView: View {
    @Binding var selectedDice: WatchDiceType
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(WatchDiceType.allCases) { dice in
                Button(action: {
                    selectedDice = dice
                    WKInterfaceDevice.current().play(.click)
                }) {
                    Text(dice.name)
                        .font(.caption2)
                        .fontWeight(selectedDice == dice ? .bold : .regular)
                        .foregroundColor(selectedDice == dice ? .white : .gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(selectedDice == dice ? Color.accentColor : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Dice Result View

struct DiceResultView: View {
    let result: Int
    let diceType: WatchDiceType
    let isAnimating: Bool
    
    var isCritical: Bool {
        result == diceType.sides
    }
    
    var isFumble: Bool {
        result == 1
    }
    
    var resultColor: Color {
        if isCritical { return .green }
        if isFumble { return .red }
        return .accentColor
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(resultColor.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Circle()
                    .strokeBorder(resultColor, lineWidth: 3)
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 4) {
                    Text("\(result)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(resultColor)
                    
                    if isCritical || isFumble {
                        Text(isCritical ? "CRIT!" : "FUMBLE!")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(resultColor)
                    }
                }
            }
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            
            Text(diceType.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Placeholder View

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "dice.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }
            
            Text("Roll to start")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Roll Button

struct RollButtonView: View {
    @Binding var isRolling: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            guard !isRolling else { return }
            action()
        }) {
            HStack {
                Image(systemName: "dice.fill")
                Text("ROLL")
                    .fontWeight(.bold)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isRolling ? Color.gray : Color.accentColor)
            )
        }
        .buttonStyle(.plain)
        .disabled(isRolling)
    }
}

// MARK: - View Model

class WatchDiceViewModel: ObservableObject {
    @Published var selectedDice: WatchDiceType = .d20
    @Published var lastResult: Int?
    @Published var isRolling = false
    @Published var rollHistory: [WatchRollRecord] = []
    
    private let historyKey = "watchRollHistory"
    
    init() {
        loadHistory()
    }
    
    func roll() {
        isRolling = true
        
        // Simulate roll animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
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
            
            self.isRolling = false
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([WatchRollRecord].self, from: data) {
            rollHistory = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(rollHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
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
