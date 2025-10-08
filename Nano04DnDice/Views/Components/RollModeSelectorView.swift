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
        VStack(spacing: 8) {
            Text("MODO DE ROLAGEM")
                .font(.custom("PlayfairDisplay-Regular", size: 11))
                .foregroundColor(Color.white.opacity(0.7))
                .tracking(1.5)
            
            VStack(spacing: 6) {
                modeButton(.normal, icon: "circle", label: "Normal")
                modeButton(.blessed, icon: "arrow.up.circle.fill", label: "Abençoado")
                modeButton(.cursed, icon: "arrow.down.circle.fill", label: "Amaldiçoado")
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
    
    // MARK: - Subviews
    
    private func modeButton(_ mode: RollMode, icon: String, label: String) -> some View {
        Button(action: { onSelectMode(mode) }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(selectedMode == mode ? .black : accentColor)
                
                Text(label)
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(selectedMode == mode ? .black : accentColor)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedMode == mode ? accentColor : Color.clear)
            )
        }
    }
}
