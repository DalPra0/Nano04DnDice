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
    
    var body: some View {
        VStack(spacing: 4) {
            OrnamentalDivider(color: accentColor)
            
            Text("ROLLING")
                .font(.custom("PlayfairDisplay-Regular", size: 11))
                .foregroundColor(Color.white.opacity(0.7))
                .tracking(1.5)
            
            Text(diceName.uppercased())
                .font(.custom("PlayfairDisplay-Black", size: 22))
                .foregroundColor(accentColor)
                .shadow(color: accentColor.opacity(0.6), radius: 8)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            OrnamentalDivider(color: accentColor)
        }
    }
}

// MARK: - Ornamental Divider Component

struct OrnamentalDivider: View {
    let color: Color
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(color.opacity(0.6))
                .frame(height: 1)
            
            Circle()
                .fill(color)
                .frame(width: 4, height: 4)
            
            Rectangle()
                .fill(color.opacity(0.6))
                .frame(height: 1)
        }
        .frame(width: 80)
    }
}
