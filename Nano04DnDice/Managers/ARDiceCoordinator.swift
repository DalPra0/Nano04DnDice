//
//  ARDiceCoordinator.swift
//  Nano04DnDice
//
//  AR Dice Logic + Physics
//

import SwiftUI
import RealityKit
import ARKit
import Combine

class ARDiceCoordinator: NSObject, ObservableObject {
    @Published var surfaceDetected = false
    @Published var isDiceThrown = false
    @Published var diceResult: Int?
    @Published var pulseAnimation = false
    
    let arView = ARView(frame: .zero)
    private var diceEntity: ModelEntity?
    private var detectedPlane: AnchorEntity?
    private var cancellables = Set<AnyCancellable>()
    private var resultCheckTimer: Timer?
    
    override init() {
        super.init()
        setupARView()
        startPulseAnimation()
    }
    
    // MARK: - Setup
    private func setupARView() {
        // Configuração da sessão AR
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal] // Detecta superfícies horizontais
        configuration.environmentTexturing = .automatic
        
        arView.session.delegate = self
        arView.automaticallyConfigureSession = false
    }
    
    func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
    }
    
    func stopSession() {
        arView.session.pause()
        resultCheckTimer?.invalidate()
    }
    
    // MARK: - Pulse Animation
    private func startPulseAnimation() {
        Timer.publish(every: 1.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                withAnimation(.easeOut(duration: 1.5)) {
                    self.pulseAnimation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.pulseAnimation = false
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Throw Dice
    func throwDice(force: Float) {
        guard surfaceDetected, let plane = detectedPlane else { return }
        
        isDiceThrown = true
        diceResult = nil
        
        // Load do modelo D20
        guard let diceModel = try? ModelEntity.loadModel(named: "D20") else {
            print("❌ Erro ao carregar D20.usdz")
            return
        }
        
        // Configura escala (ajuste se necessário)
        diceModel.scale = [0.05, 0.05, 0.05] // 5cm de diâmetro
        
        // Posição inicial: 30cm acima da superfície detectada
        diceModel.position = [0, 0.3, 0]
        
        // Adiciona física ao dado
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 0.8,
            dynamicFriction: 0.6,
            restitution: 0.3 // Quique moderado
        )
        
        // Collision shape (esfera aproximada para performance)
        let collisionShape = ShapeResource.generateSphere(radius: 0.025)
        
        diceModel.components.set(PhysicsBodyComponent(
            massProperties: .default,
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        diceModel.components.set(CollisionComponent(shapes: [collisionShape]))
        
        // Aplica força inicial (arremesso)
        let throwDirection = SIMD3<Float>(
            Float.random(in: -0.5...0.5), // Rotação X aleatória
            -force * 2, // Força pra baixo
            Float.random(in: -0.5...0.5)  // Rotação Z aleatória
        )
        
        diceModel.addForce(throwDirection, relativeTo: nil)
        
        // Aplica torque (rotação) aleatório
        let randomTorque = SIMD3<Float>(
            Float.random(in: -10...10),
            Float.random(in: -10...10),
            Float.random(in: -10...10)
        )
        diceModel.addTorque(randomTorque, relativeTo: nil)
        
        // Adiciona à cena
        plane.addChild(diceModel)
        diceEntity = diceModel
        
        // Som de arremesso
        AudioManager.shared.playDiceRoll()
        
        // Inicia timer para detectar quando o dado parar
        startResultDetection()
    }
    
    // MARK: - Result Detection
    private func startResultDetection() {
        // Aguarda 3 segundos (tempo pra dado rolar e parar)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.detectDiceResult()
        }
    }
    
    private func detectDiceResult() {
        guard let dice = diceEntity else { return }
        
        // Detecta qual face está pra cima analisando a orientação
        let rotation = dice.orientation
        let eulerAngles = rotation.eulerAngles
        
        // Lógica simplificada: mapeia rotação pra número de 1-20
        // (Em produção, você mapearia cada face específica do modelo)
        let result = mapRotationToD20Face(eulerAngles: eulerAngles)
        
        DispatchQueue.main.async {
            self.diceResult = result
            self.isDiceThrown = false // Permite jogar novamente
            
            // Remove o dado da cena após 4 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                dice.removeFromParent()
                self.diceEntity = nil
            }
        }
    }
    
    // MARK: - Helper: Mapeia rotação pra face do D20
    private func mapRotationToD20Face(eulerAngles: SIMD3<Float>) -> Int {
        // Algoritmo simplificado: gera número baseado na orientação
        // Em produção, você mapearia cada uma das 20 faces específicas do modelo
        
        let x = eulerAngles.x
        let y = eulerAngles.y
        let z = eulerAngles.z
        
        // Combina os ângulos e mapeia pra 1-20
        let combined = (x + y + z) * 100
        let normalized = abs(Int(combined)) % 20 + 1
        
        return normalized
    }
}

// MARK: - ARSessionDelegate
extension ARDiceCoordinator: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                DispatchQueue.main.async {
                    self.surfaceDetected = true
                }
                
                // Cria anchor entity na superfície detectada
                if detectedPlane == nil {
                    let anchorEntity = AnchorEntity(anchor: planeAnchor)
                    arView.scene.addAnchor(anchorEntity)
                    detectedPlane = anchorEntity
                    
                    // Adiciona um plano visual sutil
                    addSurfaceIndicator(to: anchorEntity, planeAnchor: planeAnchor)
                }
            }
        }
    }
    
    // MARK: - Surface Indicator
    private func addSurfaceIndicator(to anchor: AnchorEntity, planeAnchor: ARPlaneAnchor) {
        let extent = planeAnchor.planeExtent
        let mesh = MeshResource.generatePlane(
            width: extent.width,
            depth: extent.height
        )
        
        var material = SimpleMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.1))
        
        let planeEntity = ModelEntity(mesh: mesh, materials: [material])
        planeEntity.position = [extent.rotationOnYAxis.x, 0, extent.rotationOnYAxis.z]
        
        anchor.addChild(planeEntity)
    }
}

// MARK: - Helper Extension
extension simd_quatf {
    var eulerAngles: SIMD3<Float> {
        let x = atan2(2 * (self.vector.w * self.vector.x + self.vector.y * self.vector.z),
                      1 - 2 * (self.vector.x * self.vector.x + self.vector.y * self.vector.y))
        let y = asin(2 * (self.vector.w * self.vector.y - self.vector.z * self.vector.x))
        let z = atan2(2 * (self.vector.w * self.vector.z + self.vector.x * self.vector.y),
                      1 - 2 * (self.vector.y * self.vector.y + self.vector.z * self.vector.z))
        return SIMD3<Float>(x, y, z)
    }
}

extension ARPlaneAnchor.PlaneExtent {
    var rotationOnYAxis: SIMD2<Float> {
        return SIMD2<Float>(self.rotationOnYAxis, self.rotationOnYAxis)
    }
}
