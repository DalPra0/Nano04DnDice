//
//  ARDiceView.swift
//  Nano04DnDice
//
//  AR Dice Experience - Pokemon GO Style
//

import SwiftUI
import RealityKit
import ARKit

struct ARDiceView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var arCoordinator = ARDiceCoordinator()
    @ObservedObject var themeManager: ThemeManager
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var showResult = false
    
    private var currentTheme: DiceCustomization {
        themeManager.currentTheme
    }
    
    var body: some View {
        ZStack {
            // AR View (câmera + world tracking)
            ARViewContainer(coordinator: arCoordinator)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header com botão de fechar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(20)
                    
                    Spacer()
                }
                
                // Instruções no topo
                if !arCoordinator.surfaceDetected {
                    Text("Aponte a câmera para uma superfície plana")
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.6))
                        )
                        .padding(.top, 20)
                }
                
                Spacer()
                
                // Resultado do dado (quando parar de rolar)
                if showResult, let result = arCoordinator.diceResult {
                    VStack(spacing: 8) {
                        Text("RESULTADO")
                            .font(.custom("PlayfairDisplay-Bold", size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(3)
                        
                        Text("\(result)")
                            .font(.custom("PlayfairDisplay-Black", size: 72))
                            .foregroundColor(currentTheme.accentColor.color)
                            .shadow(color: currentTheme.accentColor.color.opacity(0.5), radius: 20, x: 0, y: 0)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding(.bottom, 200)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Dado arrastável na parte de baixo (estilo Pokémon GO)
                diceThrowArea
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            arCoordinator.startSession()
        }
        .onDisappear {
            arCoordinator.stopSession()
        }
        .onChange(of: arCoordinator.diceResult) { oldValue, newResult in
            if newResult != nil {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showResult = true
                }
                
                // Esconde o resultado depois de 3 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showResult = false
                    }
                }
            }
        }
    }
    
    // MARK: - Área do dado arrastável
    private var diceThrowArea: some View {
        VStack(spacing: 12) {
            // Indicador visual
            if arCoordinator.surfaceDetected && !arCoordinator.isDiceThrown {
                Text("ARRASTE PARA JOGAR")
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(currentTheme.accentColor.color)
                    .tracking(2)
                    .opacity(isDragging ? 0.3 : 1.0)
            }
            
            // Container do dado
            ZStack {
                // Fundo
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                arCoordinator.surfaceDetected ? currentTheme.accentColor.color : Color.gray,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: currentTheme.accentColor.color.opacity(0.3), radius: 10, x: 0, y: 4)
                
                // Ícone do dado
                Image(systemName: "dice.fill")
                    .font(.system(size: 50))
                    .foregroundColor(arCoordinator.surfaceDetected ? currentTheme.accentColor.color : .gray)
                
                // Efeito de pulso quando superfície detectada
                if arCoordinator.surfaceDetected && !arCoordinator.isDiceThrown {
                    Circle()
                        .stroke(currentTheme.accentColor.color, lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(arCoordinator.pulseAnimation ? 1.2 : 1.0)
                        .opacity(arCoordinator.pulseAnimation ? 0 : 0.8)
                }
            }
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if arCoordinator.surfaceDetected && !arCoordinator.isDiceThrown {
                            isDragging = true
                            // Só permite arrastar pra cima
                            dragOffset = min(0, value.translation.height)
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        
                        // Se arrastou pra cima com força suficiente
                        if value.translation.height < -50 && arCoordinator.surfaceDetected {
                            // Calcula a força do arremesso baseado na velocidade
                            let throwForce = min(abs(value.predictedEndTranslation.height) / 100, 5.0)
                            
                            // 🎯 POSIÇÃO DO TOQUE: Usa onde o dedo soltou (estilo Pokémon GO!)
                            let touchPoint = value.location
                            
                            // Joga o dado ONDE VOCÊ TOCOU!
                            arCoordinator.throwDice(force: Float(throwForce), at: touchPoint)
                            
                            // Feedback háptico
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                        }
                        
                        // Reseta a posição
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            dragOffset = 0
                        }
                    }
            )
            .disabled(arCoordinator.isDiceThrown)
            .opacity(arCoordinator.isDiceThrown ? 0.3 : 1.0)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.6))
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - AR View Container (UIViewRepresentable)
struct ARViewContainer: UIViewRepresentable {
    let coordinator: ARDiceCoordinator
    
    func makeUIView(context: Context) -> ARView {
        return coordinator.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Updates handled by coordinator
    }
}
