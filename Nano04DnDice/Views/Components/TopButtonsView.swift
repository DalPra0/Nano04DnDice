//
//  TopButtonsView.swift
//  Nano04DnDice
//
//  Componente - Menu Hambúrguer com overlay
//

import SwiftUI

struct TopButtonsView: View {
    let accentColor: Color
    let onShowThemes: () -> Void
    let onShowCustomizer: () -> Void
    let onShowAR: () -> Void
    
    @State private var isMenuOpen = false
    
    var body: some View {
        ZStack {
            // Overlay escuro - TELA INTEIRA (atrás dos botões do menu)
            if isMenuOpen {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isMenuOpen = false
                        }
                    }
                    .zIndex(998)
            }
            
            // Menu no canto superior direito - POR CIMA DO OVERLAY
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        // Botão Hambúrguer
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(accentColor)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        
                        // Botões do Menu - abaixo do hambúrguer
                        if isMenuOpen {
                            VStack(alignment: .trailing, spacing: 12) {
                                MenuButton(
                                    icon: "arkit",
                                    title: "AR DICE",
                                    accentColor: accentColor,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            isMenuOpen = false
                                        }
                                        onShowAR()
                                    }
                                )
                                
                                MenuButton(
                                    icon: "rectangle.stack.fill",
                                    title: "THEMES",
                                    accentColor: accentColor,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            isMenuOpen = false
                                        }
                                        onShowThemes()
                                    }
                                )
                                
                                MenuButton(
                                    icon: "paintpalette.fill",
                                    title: "CUSTOMIZE",
                                    accentColor: accentColor,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            isMenuOpen = false
                                        }
                                        onShowCustomizer()
                                    }
                                )
                            }
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            .zIndex(1001)
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

// MARK: - Menu Button Component

struct MenuButton: View {
    let icon: String
    let title: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.custom("PlayfairDisplay-Bold", size: 16))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentColor)
            )
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
