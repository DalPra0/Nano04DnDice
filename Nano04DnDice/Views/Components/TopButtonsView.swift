//
//  TopButtonsView.swift
//  Nano04DnDice
//
//  Componente - Botões do topo MENORES
//

import SwiftUI

struct TopButtonsView: View {
    let accentColor: Color
    let onShowThemes: () -> Void
    let onShowCustomizer: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            TopButton(
                icon: "rectangle.stack.fill",
                title: "TEMAS",
                accentColor: accentColor,
                action: onShowThemes
            )
            
            TopButton(
                icon: "paintpalette.fill",
                title: "CUSTOMIZAR",
                accentColor: accentColor,
                action: onShowCustomizer
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Top Button Component

struct TopButton: View {
    let icon: String
    let title: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.custom("PlayfairDisplay-Bold", size: 12))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor)
                    .shadow(color: accentColor.opacity(0.5), radius: 5)
            )
        }
    }
}
