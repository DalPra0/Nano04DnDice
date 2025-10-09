//
//  RollModeSelectorView.swift
//  Nano04DnDice
//
//  Component - COLLAPSIBLE Roll Mode Selector
//

import SwiftUI

struct RollModeSelectorView: View {
    let selectedMode: RollMode
    let accentColor: Color
    let onSelectMode: (RollMode) -> Void
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Always visible (collapsible)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("ROLL MODE")
                        .font(.custom("PlayfairDisplay-Bold", size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Current mode indicator
                    Text(selectedMode.displayName)
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(accentColor)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(accentColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                        )
                )
            }
            
            // Expandable content
            if isExpanded {
                VStack(spacing: 6) {
                    modeButton(.normal, icon: "circle", label: "Normal")
                    modeButton(.blessed, icon: "arrow.up.circle.fill", label: "Blessed")
                    modeButton(.cursed, icon: "arrow.down.circle.fill", label: "Cursed")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.3))
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    // MARK: - Subviews
    
    private func modeButton(_ mode: RollMode, icon: String, label: String) -> some View {
        Button(action: { 
            onSelectMode(mode)
            // Fecha o accordion automaticamente após selecionar
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded = false
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(selectedMode == mode ? .black : accentColor)
                
                Text(label)
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
                    .foregroundColor(selectedMode == mode ? .black : accentColor)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedMode == mode ? accentColor : Color.clear)
            )
        }
    }
}
