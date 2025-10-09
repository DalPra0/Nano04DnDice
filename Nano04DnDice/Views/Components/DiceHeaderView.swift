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
        VStack(spacing: 6) {
            OrnamentalDivider(color: accentColor)
            
            Text("ROLLING")
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .foregroundColor(Color.white.opacity(0.7))
                .tracking(2)
            
            Text(diceName.uppercased())
                .font(.custom("PlayfairDisplay-Black", size: 32))
                .foregroundColor(accentColor)
                .shadow(color: accentColor.opacity(0.6), radius: 12)
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
                .frame(height: 1.5)
            
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            Rectangle()
                .fill(color.opacity(0.6))
                .frame(height: 1.5)
        }
        .frame(width: 120)
    }
}
