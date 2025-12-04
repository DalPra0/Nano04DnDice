
import SwiftUI
import RealityKit
import ARKit

struct ARDiceView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var arCoordinator = ARDiceCoordinator()
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    @State private var showResult = false
    
    private var currentTheme: DiceCustomization {
        themeManager.currentTheme
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(coordinator: arCoordinator)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Fechar visualização AR")
                    .accessibilityHint("Volta para a tela principal")
                    .padding(20)
                    
                    Spacer()
                }
                
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
                        .accessibilityLabel("Procurando superfície")
                        .accessibilityHint("Mova o dispositivo lentamente sobre uma superfície plana como mesa ou chão")
                }
                
                Spacer()
                
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
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Resultado: \(result)")
                    .accessibilityAddTraits(.updatesFrequently)
                }
                
                Spacer()
                
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
            if let result = newResult {
                if reduceMotion {
                    showResult = true
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showResult = true
                    }
                }
                
                UIAccessibility.post(notification: .announcement, argument: "Resultado: \(result)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if reduceMotion {
                        showResult = false
                    } else {
                        withAnimation {
                            showResult = false
                        }
                    }
                }
            }
        }
    }
    
    private var diceThrowArea: some View {
        VStack(spacing: 12) {
            if arCoordinator.surfaceDetected && !arCoordinator.isDiceThrown {
                Text("SEGURE E ARRASTE PARA ARREMESSAR")
                    .font(.custom("PlayfairDisplay-Bold", size: 14))
                    .foregroundColor(currentTheme.accentColor.color)
                    .tracking(2)
                    .opacity(isDragging ? 0.3 : 1.0)
                    .accessibilityLabel("Arraste o dado para arremessar")
                    .accessibilityHint("Arraste em qualquer direção. Quanto mais longe, mais forte o arremesso")
            }
            
            ZStack {
                if !arCoordinator.isDiceThrown {
                    ZStack {
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
                        
                        Image(systemName: "dice.fill")
                            .font(.system(size: 70))
                            .foregroundColor(currentTheme.accentColor.color)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Circle()
                            .stroke(currentTheme.accentColor.color, lineWidth: 3)
                            .frame(width: 100, height: 100)
                            .opacity(isDragging ? 0.8 : 0.3)
                            .scaleEffect(isDragging ? 1.1 : 1.0)
                        
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
                    .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                    .accessibilityLabel(arCoordinator.surfaceDetected ? "Dado pronto para arremessar" : "Aguardando detecção de superfície")
                    .accessibilityHint(arCoordinator.surfaceDetected ? "Toque duas vezes para arremessar com força média para frente" : "")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction {
                        if arCoordinator.surfaceDetected {
                            arCoordinator.throwDice(
                                force: 4.0,
                                direction: SIMD3<Float>(0, 0, -1),
                                at: CGPoint(x: 200, y: 400)
                            )
                            UIAccessibility.post(notification: .announcement, argument: "Dado arremessado")
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        Text("Dado arremessado!")
                            .font(.custom("PlayfairDisplay-Regular", size: 14))
                            .foregroundColor(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Dado arremessado")
                    .accessibilityHint("Aguardando resultado")
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
                        
                        if arCoordinator.surfaceDetected && !arCoordinator.isDiceThrown {
                            
                            let dragDistance = sqrt(
                                pow(value.translation.width, 2) +
                                pow(value.translation.height, 2)
                            )
                            
                            let dragVelocity = sqrt(
                                pow(value.predictedEndTranslation.width, 2) +
                                pow(value.predictedEndTranslation.height, 2)
                            )
                            
                            let throwForce = min((dragDistance + dragVelocity) / 150, 8.0)
                            
                            let directionX = Float(value.translation.width / max(dragDistance, 1))
                            let directionY = Float(value.translation.height / max(dragDistance, 1))
                            
                            let touchPoint = value.location
                            
                            if dragDistance > 30 { // Mínimo de arrasto para ativar
                                arCoordinator.throwDice(
                                    force: Float(throwForce),
                                    direction: SIMD3<Float>(directionX, -directionY, -1),
                                    at: touchPoint
                                )
                                
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            }
                        }
                        
                        if reduceMotion {
                            dragOffset = .zero
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                dragOffset = .zero
                            }
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

struct ARViewContainer: UIViewRepresentable {
    let coordinator: ARDiceCoordinator
    
    func makeUIView(context: Context) -> ARView {
        return coordinator.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}
