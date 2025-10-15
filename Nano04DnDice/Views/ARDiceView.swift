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
    @State private var dragOffset: CGSize = .zero
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
                Text("SEGURE E ARRASTE PARA ARREMESSAR")
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(currentTheme.accentColor.color)
                    .tracking(2)
                    .opacity(isDragging ? 0.3 : 1.0)
            }
            
            // Container do dado - POKÉMON GO STYLE!
            ZStack {
                // Dado 3D na sua "mão" (sempre visível quando não arremessado)
                if !arCoordinator.isDiceThrown {
                    ZStack {
                        // Sombra/glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        currentTheme.accentColor.color.opacity(0.3),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                        
                        // Ícone do dado GRANDE (você segura ele!)
                        Image(systemName: "dice.fill")
                            .font(.system(size: 70))
                            .foregroundColor(currentTheme.accentColor.color)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        // Efeito de "segurar" - círculo ao redor
                        Circle()
                            .stroke(currentTheme.accentColor.color, lineWidth: 3)
                            .frame(width: 100, height: 100)
                            .opacity(isDragging ? 0.8 : 0.3)
                            .scaleEffect(isDragging ? 1.1 : 1.0)
                        
                        // Efeito de pulso quando superfície detectada
                        if arCoordinator.surfaceDetected {
                            Circle()
                                .stroke(currentTheme.accentColor.color, lineWidth: 2)
                                .frame(width: 120, height: 120)
                                .scaleEffect(arCoordinator.pulseAnimation ? 1.3 : 1.0)
                                .opacity(arCoordinator.pulseAnimation ? 0 : 0.6)
                        }
                    }
                    .offset(x: isDragging ? dragOffset.width : 0,
                           y: isDragging ? dragOffset.height : 0)
                    .scaleEffect(isDragging ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                } else {
                    // Dado foi arremessado - mostra feedback
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        Text("Dado arremessado!")
                            .font(.custom("PlayfairDisplay-Regular", size: 14))
                            .foregroundColor(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 200)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if arCoordinator.surfaceDetected && !arCoordinator.isDiceThrown {
                            isDragging = true
                            dragOffset = CGSize(
                                width: value.translation.width,
                                height: value.translation.height
                            )
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        
                        // Calcula a força e direção do arremesso
                        if arCoordinator.surfaceDetected && !arCoordinator.isDiceThrown {
                            
                            // Distância total do arrasto
                            let dragDistance = sqrt(
                                pow(value.translation.width, 2) +
                                pow(value.translation.height, 2)
                            )
                            
                            // Velocidade do arrasto
                            let dragVelocity = sqrt(
                                pow(value.predictedEndTranslation.width, 2) +
                                pow(value.predictedEndTranslation.height, 2)
                            )
                            
                            // Força baseada em distância E velocidade
                            let throwForce = min((dragDistance + dragVelocity) / 150, 8.0)
                            
                            // Direção normalizada (-1 a 1 para X e Y)
                            let directionX = Float(value.translation.width / max(dragDistance, 1))
                            let directionY = Float(value.translation.height / max(dragDistance, 1))
                            
                            // Posição do toque (onde soltou)
                            let touchPoint = value.location
                            
                            if dragDistance > 30 { // Mínimo de arrasto para ativar
                                // 🎯 ARREMESSA o dado com direção e força!
                                arCoordinator.throwDice(
                                    force: Float(throwForce),
                                    direction: SIMD3<Float>(directionX, -directionY, -1),
                                    at: touchPoint
                                )
                                
                                // Feedback háptico FORTE
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            }
                        }
                        
                        // Reseta a posição
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            dragOffset = .zero
                        }
                    }
            )
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
