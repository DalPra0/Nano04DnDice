//
//  DnDiceWatchAppApp.swift
//  DnDiceWatchApp Watch App
//
//  Created by Lucas Dal Pra Brascher on 04/12/25.
//

import SwiftUI

@main
struct DnDiceWatchApp_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRootView()
        }
    }
}

// MARK: - Root Navigation (NavigationStack - watchOS 10+)
struct WatchRootView: View {
    @StateObject private var viewModel = WatchDiceViewModel.shared
    
    var body: some View {
        NavigationStack {
            List {
                // Primary action - Roll dice
                Section {
                    NavigationLink(destination: ContentView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Roll Dice")
                                    .font(.headline)
                                if let lastResult = viewModel.lastResult {
                                    Text("Last: \(lastResult)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "dice.fill")
                                .foregroundColor(.accentColor)
                                .imageScale(.large)
                        }
                    }
                }
                
                // Quick access to specific dice
                Section("Quick Roll") {
                    ForEach(WatchDiceType.allCases) { dice in
                        NavigationLink(destination: QuickRollView(diceType: dice)) {
                            Label {
                                Text(dice.name)
                                    .font(.body)
                            } icon: {
                                Image(systemName: "die.face.\(dice.iconNumber).fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                
                // History
                Section {
                    NavigationLink(destination: HistoryView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("History")
                                    .font(.headline)
                                Text("\(viewModel.rollHistory.count) rolls")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.orange)
                                .imageScale(.large)
                        }
                    }
                }
            }
            .navigationTitle("D&D Dice")
        }
    }
}
