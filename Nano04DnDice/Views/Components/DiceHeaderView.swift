//
//  DiceHeaderView.swift
//  Nano04DnDice
//
//  Componente - Header COMPACTO
//

import SwiftUI

struct DiceHeaderView: View {
    let diceName: String
    let accentColor: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            OrnamentalDivider(color: accentColor)
            
            // ROLLING D** - Tudo em uma linha só
            HStack(spacing: 6) {
                Text("ROLLING")
                    .font(.custom("PlayfairDisplay-Bold", size: 20))
                    .foregroundColor(backgroundColor.contrastTextSecondary)
                    .tracking(3)
                
                Text(diceName.uppercased())
                    .font(.custom("PlayfairDisplay-Black", size: 40))
                    .foregroundColor(accentColor)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            
            OrnamentalDivider(color: accentColor)
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

// MARK: - Ornamental Divider Component

struct OrnamentalDivider: View {
    let color: Color
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(color.opacity(0.6))
                .frame(height: 1.5)
            
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            Rectangle()
                .fill(color.opacity(0.6))
                .frame(height: 1.5)
        }
        .frame(width: 120)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
