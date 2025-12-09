
//
//  HistoryView.swift
//  DnDiceWatchApp Watch App
//
//  Created by Lucas Dal Pra Brascher on 04/12/25.
//

import SwiftUI
import Combine

struct HistoryView: View {
    @StateObject private var viewModel = WatchDiceViewModel.shared
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    var body: some View {
        List {
            if viewModel.rollHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No rolls yet")
                        .font(.body) // 17pt (was caption 12pt)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.rollHistory.prefix(20)) { record in
                    HistoryRowView(record: record, isAOD: isLuminanceReduced)
                }
            }
        }
        .navigationTitle("History")
    }
}

struct HistoryRowView: View {
    let record: WatchRollRecord
    let isAOD: Bool
    
    var isCritical: Bool {
        record.result == record.dice.sides
    }
    
    var isFumble: Bool {
        record.result == 1
    }
    
    var resultColor: Color {
        if isAOD { return .white }
        if isCritical { return .green }
        if isFumble { return .red }
        return .primary
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Dice type
            Text(record.dice.name)
                .font(.footnote) // 13pt (was caption 12pt)
                .foregroundColor(.secondary)
                .frame(width: 35, alignment: .leading)
            
            // Result (larger, bold)
            Text("\(record.result)")
                .font(.title3) // 20pt (was headline 17pt)
                .fontWeight(.bold)
                .foregroundColor(resultColor)
            
            Spacer()
            
            // Critical/Fumble indicator
            if !isAOD {
                if isCritical {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else if isFumble {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Time ago
            Text(timeAgo(from: record.date))
                .font(.caption) // 12pt
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        
        if seconds < 60 {
            return "\(seconds)s"
        } else if seconds < 3600 {
            return "\(seconds / 60)m"
        } else if seconds < 86400 {
            return "\(seconds / 3600)h"
        } else {
            return "\(seconds / 86400)d"
        }
    }
}

#Preview {
    NavigationView {
        HistoryView()
    }
}
