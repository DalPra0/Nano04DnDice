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
                title: "THEMES",
                accentColor: accentColor,
                action: onShowThemes
            )
            
            TopButton(
                icon: "paintpalette.fill",
                title: "CUSTOMIZE",
                accentColor: accentColor,
                action: onShowCustomizer
            )
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
        .padding(.bottom, 2)
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
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.custom("PlayfairDisplay-Bold", size: 10))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(accentColor)
                    .shadow(color: accentColor.opacity(0.4), radius: 3)
            )
        }
    }
}
