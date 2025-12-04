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

struct WatchRootView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Roll", systemImage: "dice.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            
            QuickAccessView()
                .tabItem {
                    Label("Quick", systemImage: "bolt.fill")
                }
        }
    }
}

struct QuickAccessView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Quick Rolls") {
                    ForEach(WatchDiceType.allCases) { dice in
                        NavigationLink(destination: QuickRollView(diceType: dice)) {
                            HStack {
                                Image(systemName: "dice.fill")
                                    .foregroundColor(.accentColor)
                                Text(dice.name)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Quick Roll")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
