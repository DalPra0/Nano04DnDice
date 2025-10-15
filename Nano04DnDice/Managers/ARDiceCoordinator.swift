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
        
        // Debug: Lista arquivos .usdz IMEDIATAMENTE
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let allFiles = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                let usdzFiles = allFiles.filter { $0.hasSuffix(".usdz") }
                if !usdzFiles.isEmpty {
                    print("✅ D20.usdz está no bundle? \(usdzFiles.contains("D20.usdz"))")
                } else {
                }
            }
            
            // Verifica subpasta Models/
            let modelsPath = (resourcePath as NSString).appendingPathComponent("Models")
            if fileManager.fileExists(atPath: modelsPath) {
                if let modelFiles = try? fileManager.contentsOfDirectory(atPath: modelsPath) {
                }
            } else {
            }
        }
        
        // Testa Bundle.main.url
        if let url = Bundle.main.url(forResource: "D20", withExtension: "usdz") {
        } else {
        }
        
        
        setupARView()
        startPulseAnimation()
    }
    
    // MARK: - Setup
    private func setupARView() {
        // Configuração da sessão AR
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal] // Detecta superfícies horizontais
        configuration.environmentTexturing = .automatic
        
        // Enable scene reconstruction if device supports it (better geometry for raycasts)
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }

        // Enable frame semantics for scene depth if available (improves occlusion)
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }

        arView.session.delegate = self
        arView.automaticallyConfigureSession = false
        
        // ⚡ CRÍTICO: Habilita física e gravidade no ARView
        arView.environment.background = .cameraFeed()
        
        // Configura física global
        var physicsOrigin = PhysicsBodyComponent()
        physicsOrigin.mode = .static
        
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
    func throwDice(force: Float, at screenPoint: CGPoint? = nil) {
        
        guard surfaceDetected, let plane = detectedPlane else {
            return
        }
        
        isDiceThrown = true
        diceResult = nil
        
        
        // DEBUG: Verifica bundle resources
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            
            // Lista TUDO no bundle
            if let allFiles = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                let usdzFiles = allFiles.filter { $0.hasSuffix(".usdz") }
            }
            
            // Verifica subpastas
            let modelsPath = (resourcePath as NSString).appendingPathComponent("Models")
            if fileManager.fileExists(atPath: modelsPath) {
                if let modelFiles = try? fileManager.contentsOfDirectory(atPath: modelsPath) {
                }
            } else {
            }
            
            // Busca recursiva por D20.usdz
            if let enumerator = fileManager.enumerator(atPath: resourcePath) {
                let d20Files = enumerator.allObjects.compactMap { $0 as? String }.filter { $0.contains("D20") }
            }
        }
        
        // TENTATIVA 1: Bundle.main.url (MAIS CONFIÁVEL)
        if let url = Bundle.main.url(forResource: "D20", withExtension: "usdz") {
            
            // CARREGAMENTO SÍNCRONO (funciona melhor no RealityKit!)
            do {
                let loadedEntity = try Entity.load(contentsOf: url)
                
                var dice: ModelEntity?
                
                // Função recursiva para encontrar ModelEntity
                func findModel(in entity: Entity) -> ModelEntity? {
                    if let model = entity as? ModelEntity, model.model != nil {
                        return model
                    }
                    for child in entity.children {
                        if let found = findModel(in: child) {
                            return found
                        }
                    }
                    return nil
                }
                
                dice = findModel(in: loadedEntity)
                
                if let finalDice = dice {
                    self.applyPhysicsAndThrow(to: finalDice, force: force, plane: plane, screenPoint: screenPoint)
                } else {
                    self.throwFallbackDice(force: force, plane: plane, screenPoint: screenPoint)
                }
                
            } catch {
                self.throwFallbackDice(force: force, plane: plane)
            }
            return
        }
        
        // Se chegou aqui, Bundle.main.url não encontrou
        throwFallbackDice(force: force, plane: plane)
    }
    
    // MARK: - Helper: Aplicar física e jogar
    private func applyPhysicsAndThrow(to dice: ModelEntity, force: Float, plane: AnchorEntity) {
        
        // Configura escala - MAIOR para visualizar melhor!
        dice.scale = [0.1, 0.1, 0.1] // 10cm (antes era 5cm)
        
        // Posição inicial: ACIMA da superfície detectada, NA FRENTE da câmera
        // Y = 0.3 (30cm acima do plano)
        // Z = -0.3 (30cm na frente da câmera, mais próximo)
        dice.position = [0, 0.3, -0.3]
        
        
        // FÍSICA MELHORADA - collision mais precisa
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 1.0,  // Mais atrito (não desliza muito)
            dynamicFriction: 0.8, // Atrito ao mover
            restitution: 0.2      // Pouco quique (mais realista)
        )
        
        // ⚡ CRÍTICO: Gera collision shapes automaticamente do modelo (evita atravessamento!)
        dice.generateCollisionShapes(recursive: true)
        
        // Sobrescreve com PhysicsBody
        dice.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: 0.05), // 50g (peso de um dado real)
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        // Se generateCollisionShapes falhou, usa box como fallback
        if dice.collision == nil {
            let collisionShape = ShapeResource.generateBox(width: 0.1, height: 0.1, depth: 0.1)
            dice.components.set(CollisionComponent(
                shapes: [collisionShape],
                mode: .default,
                filter: .default
            ))
        }
        
        // Aplica força inicial (arremesso) - MENOR pra não sair voando
        let throwDirection = SIMD3<Float>(
            Float.random(in: -0.2...0.2), // Menos rotação lateral
            -force * 0.5,                 // Metade da força (antes era *2)
            Float.random(in: -0.2...0.2)  // Menos rotação frente/trás
        )
        
        dice.addForce(throwDirection, relativeTo: nil)
        
        // Aplica torque (rotação) aleatório - MENOR
        let randomTorque = SIMD3<Float>(
            Float.random(in: -3...3),  // Antes era -10...10
            Float.random(in: -3...3),
            Float.random(in: -3...3)
        )
        dice.addTorque(randomTorque, relativeTo: nil)
        
        // ⚡ POSICIONAMENTO ROBUSTO: Usa raycast para colocar o dado no mundo real
        let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        // Tenta múltiplas estratégias de raycast
        var raycastResults = arView.raycast(from: centerPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
        if raycastResults.isEmpty {
            // Fallback: tenta com estimated plane
            raycastResults = arView.raycast(from: centerPoint, allowing: .estimatedPlane, alignment: .horizontal)
        }
        
        if let raycastResult = raycastResults.first {
            let worldTransform = raycastResult.worldTransform
            
            // Extrai posição do mundo
            let translation = SIMD3<Float>(
                worldTransform.columns.3.x,
                worldTransform.columns.3.y,
                worldTransform.columns.3.z
            )
            
            
            // Cria ARAnchor no ponto exato
            let arAnchor = ARAnchor(transform: worldTransform)
            arView.session.add(anchor: arAnchor)
            
            let spawnAnchor = AnchorEntity(anchor: arAnchor)
            
            // Posiciona dado 30cm ACIMA do ponto detectado
            dice.position = [0, 0.3, 0]
            
            spawnAnchor.addChild(dice)
            arView.scene.addAnchor(spawnAnchor)
            diceEntity = dice
            
        } else {
            // Fallback: usa plane anchor
            dice.position = [0, 0.3, -0.3]
            plane.addChild(dice)
            diceEntity = dice
        }


        // Som de arremesso
        Nano04DnDice.AudioManager.shared.playDiceRoll()

        // Inicia detecção de resultado
        startResultDetection()
    }
    
    // MARK: - Helper: Dado Fallback (esfera dourada)
    private func throwFallbackDice(force: Float, plane: AnchorEntity) {
        
        // Cria um dado fallback (esfera simples)
        let mesh = MeshResource.generateSphere(radius: 0.05) // 5cm de raio
        var material = SimpleMaterial()
        material.color = .init(tint: .systemYellow)
        material.metallic = .float(0.8)
        material.roughness = .float(0.2)
        
        let fallbackDice = ModelEntity(mesh: mesh, materials: [material])
        
        
        // Adiciona física - MESMA configuração do dado real
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 1.0,
            dynamicFriction: 0.8,
            restitution: 0.2
        )
        
        // Gera collision automática da esfera
        fallbackDice.generateCollisionShapes(recursive: false)
        
        fallbackDice.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: 0.05),
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        // Se collision auto falhou, usa sphere shape
        if fallbackDice.collision == nil {
            let collisionShape = ShapeResource.generateSphere(radius: 0.05)
            fallbackDice.components.set(CollisionComponent(
                shapes: [collisionShape],
                mode: .default,
                filter: .default
            ))
        }
        
        // Aplica força - MESMA do dado real
        let throwDirection = SIMD3<Float>(
            Float.random(in: -0.2...0.2),
            -force * 0.5,
            Float.random(in: -0.2...0.2)
        )
        
        let randomTorque = SIMD3<Float>(
            Float.random(in: -3...3),
            Float.random(in: -3...3),
            Float.random(in: -3...3)
        )
        
        // ⚡ POSICIONAMENTO ROBUSTO (mesmo do dado principal)
        let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        var raycastResults = arView.raycast(from: centerPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
        if raycastResults.isEmpty {
            raycastResults = arView.raycast(from: centerPoint, allowing: .estimatedPlane, alignment: .horizontal)
        }
        
        if let raycastResult = raycastResults.first {
            let worldTransform = raycastResult.worldTransform
            let arAnchor = ARAnchor(transform: worldTransform)
            arView.session.add(anchor: arAnchor)
            let spawnAnchor = AnchorEntity(anchor: arAnchor)
            fallbackDice.position = [0, 0.3, 0]
            spawnAnchor.addChild(fallbackDice)
            arView.scene.addAnchor(spawnAnchor)
            diceEntity = fallbackDice
        } else {
            fallbackDice.position = [0, 0.3, -0.3]
            plane.addChild(fallbackDice)
            diceEntity = fallbackDice
        }
        
        fallbackDice.addForce(throwDirection, relativeTo: nil)
        fallbackDice.addTorque(randomTorque, relativeTo: nil)
        
        
        Nano04DnDice.AudioManager.shared.playDiceRoll()
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
        
        // Calcula euler angles diretamente
        let x = atan2(2 * (rotation.vector.w * rotation.vector.x + rotation.vector.y * rotation.vector.z),
                      1 - 2 * (rotation.vector.x * rotation.vector.x + rotation.vector.y * rotation.vector.y))
        let y = asin(2 * (rotation.vector.w * rotation.vector.y - rotation.vector.z * rotation.vector.x))
        let z = atan2(2 * (rotation.vector.w * rotation.vector.z + rotation.vector.x * rotation.vector.y),
                      1 - 2 * (rotation.vector.y * rotation.vector.y + rotation.vector.z * rotation.vector.z))
        let eulerAngles = SIMD3<Float>(x, y, z)
        
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
        // 🎯 SOLUÇÃO: Plano GIGANTE invisível que cobre todo o chão (10m x 10m)
        // Assim o dado NUNCA cai infinito, não importa onde você jogue!
        
        // Mesh visual PEQUENO (só para indicar onde foi detectado)
        let extent = planeAnchor.planeExtent
        let mesh = MeshResource.generatePlane(
            width: extent.width,
            depth: extent.height
        )
        
        var material = SimpleMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.1))
        
        let visualPlane = ModelEntity(mesh: mesh, materials: [material])
        visualPlane.position = [0, 0, 0]
        
        // ⚡ FÍSICA: Plano GIGANTE invisível (10m x 10m) - SEMPRE pega o dado!
        let GIANT_SIZE: Float = 10.0 // 10 metros
        let planeShape = ShapeResource.generateBox(
            width: GIANT_SIZE,
            height: 0.05, // 5cm de espessura para garantir colisão
            depth: GIANT_SIZE
        )
        
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 1.0,
            dynamicFriction: 0.8,
            restitution: 0.1 // Pouco bounce
        )
        
        // Entidade INVISÍVEL com física gigante
        let physicsPlane = ModelEntity()
        physicsPlane.position = [0, -0.025, 0] // 2.5cm abaixo para centralizar a caixa
        
        physicsPlane.components.set(PhysicsBodyComponent(
            massProperties: .default,
            material: physicsMaterial,
            mode: .static // ESTÁTICO = não se move, mas colide!
        ))
        
        physicsPlane.components.set(CollisionComponent(
            shapes: [planeShape],
            mode: .default,
            filter: .default
        ))
        
        // Adiciona ambos (visual pequeno + física gigante)
        anchor.addChild(visualPlane)
        anchor.addChild(physicsPlane)
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
