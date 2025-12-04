
//
//  HistoryView.swift
//  DnDiceWatchApp Watch App
//
//  Created by Lucas Dal Pra Brascher on 04/12/25.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = WatchDiceViewModel()
    
    var body: some View {
        List {
            if viewModel.rollHistory.isEmpty {
                Text("No rolls yet")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ForEach(viewModel.rollHistory.prefix(20)) { record in
                    HistoryRowView(record: record)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HistoryRowView: View {
    let record: WatchRollRecord
    
    var isCritical: Bool {
        record.result == record.dice.sides
    }
    
    var isFumble: Bool {
        record.result == 1
    }
    
    var resultColor: Color {
        if isCritical { return .green }
        if isFumble { return .red }
        return .primary
    }
    
    var body: some View {
        HStack {
            Text(record.dice.name)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
            
            Text("\(record.result)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(resultColor)
            
            Spacer()
            
            if isCritical {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else if isFumble {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
            
            Text(timeAgo(from: record.date))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
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
