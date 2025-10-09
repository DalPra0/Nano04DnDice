//
//  RollModeSelectorView.swift
//  Nano04DnDice
//
//  Componente - Seletor SUPER COMPACTO
//

import SwiftUI

struct RollModeSelectorView: View {
    let selectedMode: RollMode
    let accentColor: Color
    let onSelectMode: (RollMode) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text("ROLL MODE")
                .font(.custom("PlayfairDisplay-Regular", size: 9))
                .foregroundColor(Color.white.opacity(0.7))
                .tracking(1)
            
            VStack(spacing: 3) {
                modeButton(.normal, icon: "circle", label: "Normal")
                modeButton(.blessed, icon: "arrow.up.circle.fill", label: "Blessed")
                modeButton(.cursed, icon: "arrow.down.circle.fill", label: "Cursed")
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
    
    // MARK: - Subviews
    
    private func modeButton(_ mode: RollMode, icon: String, label: String) -> some View {
        Button(action: { onSelectMode(mode) }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(selectedMode == mode ? .black : accentColor)
                
                Text(label)
                    .font(.custom("PlayfairDisplay-Bold", size: 12))
                    .foregroundColor(selectedMode == mode ? .black : accentColor)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(selectedMode == mode ? accentColor : Color.clear)
            )
        }
    }
}
