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
        guard surfaceDetected, let plane = detectedPlane else {
            print("⚠️ Superfície não detectada ou anchor nulo")
            return
        }
        
        isDiceThrown = true
        diceResult = nil
        
        // Load do modelo D20 - tentando diferentes formas
        var diceModel: ModelEntity?
        
        // Tentativa 1: Nome direto
        if let model = try? ModelEntity.loadModel(named: "D20") {
            diceModel = model
            print("✅ D20 carregado com nome 'D20'")
        }
        // Tentativa 2: Com extensão
        else if let model = try? ModelEntity.loadModel(named: "D20.usdz") {
            diceModel = model
            print("✅ D20 carregado com nome 'D20.usdz'")
        }
        // Tentativa 3: Bundle path
        else if let url = Bundle.main.url(forResource: "D20", withExtension: "usdz") {
            do {
                let loadedEntity = try ModelEntity.load(contentsOf: url)
                // ModelEntity.load retorna Entity, então precisamos buscar o ModelEntity filho
                if let model = loadedEntity as? ModelEntity {
                    diceModel = model
                    print("✅ D20 carregado via Bundle URL (cast direto): \(url)")
                } else if let model = loadedEntity.children.first as? ModelEntity {
                    diceModel = model
                    print("✅ D20 carregado via Bundle URL (primeiro filho): \(url)")
                } else {
                    print("⚠️ Entity carregado mas não é ModelEntity")
                }
            } catch {
                print("❌ Erro ao carregar de URL: \(error)")
            }
        }
        else {
            print("❌ Erro ao carregar D20.usdz de TODAS as formas")
            print("📁 Verifique se o arquivo está no target e em Resources/Models/")
            
            // Lista todos os .usdz no bundle para debug
            if let resourcePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                if let files = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                    let usdzFiles = files.filter { $0.hasSuffix(".usdz") }
                    print("📦 Arquivos .usdz encontrados: \(usdzFiles)")
                }
            }
            
            isDiceThrown = false
            return
        }
        
        guard let dice = diceModel else {
            print("❌ Modelo é nulo após tentativas")
            print("🎲 Usando dado FALLBACK (esfera dourada)")
            
            // Cria um dado fallback (esfera simples)
            let mesh = MeshResource.generateSphere(radius: 0.025)
            var material = SimpleMaterial()
            material.color = .init(tint: .systemYellow)
            material.metallic = .float(0.8)
            material.roughness = .float(0.2)
            
            let fallbackDice = ModelEntity(mesh: mesh, materials: [material])
            fallbackDice.position = [0, 0.3, 0]
            
            // Adiciona física
            let physicsMaterial = PhysicsMaterialResource.generate(
                staticFriction: 0.8,
                dynamicFriction: 0.6,
                restitution: 0.5
            )
            
            let collisionShape = ShapeResource.generateSphere(radius: 0.025)
            
            fallbackDice.components.set(PhysicsBodyComponent(
                massProperties: .default,
                material: physicsMaterial,
                mode: .dynamic
            ))
            
            fallbackDice.components.set(CollisionComponent(shapes: [collisionShape]))
            
            // Aplica força
            let throwDirection = SIMD3<Float>(
                Float.random(in: -0.5...0.5),
                -force * 2,
                Float.random(in: -0.5...0.5)
            )
            fallbackDice.addForce(throwDirection, relativeTo: nil)
            
            let randomTorque = SIMD3<Float>(
                Float.random(in: -10...10),
                Float.random(in: -10...10),
                Float.random(in: -10...10)
            )
            fallbackDice.addTorque(randomTorque, relativeTo: nil)
            
            plane.addChild(fallbackDice)
            diceEntity = fallbackDice
            
            AudioManager.shared.playDiceRoll()
            startResultDetection()
            return
        }
        
        print("🎲 Configurando dado...")
        
        // Configura escala (ajuste se necessário)
        dice.scale = [0.05, 0.05, 0.05] // 5cm de diâmetro
        
        // Posição inicial: 30cm acima da superfície detectada
        dice.position = [0, 0.3, 0]
        
        print("📍 Posição do dado: \(dice.position)")
        
        // Adiciona física ao dado
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 0.8,
            dynamicFriction: 0.6,
            restitution: 0.3 // Quique moderado
        )
        
        // Collision shape (esfera aproximada para performance)
        let collisionShape = ShapeResource.generateSphere(radius: 0.025)
        
        dice.components.set(PhysicsBodyComponent(
            massProperties: .default,
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        dice.components.set(CollisionComponent(shapes: [collisionShape]))
        
        // Aplica força inicial (arremesso)
        let throwDirection = SIMD3<Float>(
            Float.random(in: -0.5...0.5), // Rotação X aleatória
            -force * 2, // Força pra baixo
            Float.random(in: -0.5...0.5)  // Rotação Z aleatória
        )
        
        dice.addForce(throwDirection, relativeTo: nil)
        
        // Aplica torque (rotação) aleatório
        let randomTorque = SIMD3<Float>(
            Float.random(in: -10...10),
            Float.random(in: -10...10),
            Float.random(in: -10...10)
        )
        dice.addTorque(randomTorque, relativeTo: nil)
        
        print("💫 Força aplicada: \(throwDirection)")
        print("🌀 Torque aplicado: \(randomTorque)")
        
        // Adiciona à cena
        plane.addChild(dice)
        diceEntity = dice
        
        print("✅ Dado adicionado à cena!")
        
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
        planeEntity.position = [0, 0, 0] // Centralizado no anchor
        
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
