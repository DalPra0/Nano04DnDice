
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
    
    private func setupARView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal] // Detecta superfícies horizontais
        configuration.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh

        }

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }

        arView.session.delegate = self
        arView.automaticallyConfigureSession = false
        
        arView.environment.background = .cameraFeed()
        
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
    
    func throwDice(force: Float, direction: SIMD3<Float> = SIMD3(0, -1, -1), at screenPoint: CGPoint? = nil) {
        
        guard surfaceDetected, let plane = detectedPlane else {
            return
        }
        
        isDiceThrown = true
        diceResult = nil
        
        if let url = Bundle.main.url(forResource: "D20", withExtension: "usdz") {
            
            do {
                let loadedEntity = try Entity.load(contentsOf: url)
                
                var dice: ModelEntity?
                
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
                    self.applyPhysicsAndThrow(to: finalDice, force: force, direction: direction, plane: plane, screenPoint: screenPoint)
                } else {
                    self.throwFallbackDice(force: force, direction: direction, plane: plane, screenPoint: screenPoint)
                }
                
            } catch {
                self.throwFallbackDice(force: force, direction: direction, plane: plane, screenPoint: screenPoint)
            }
            return
        }
        
        throwFallbackDice(force: force, direction: direction, plane: plane, screenPoint: screenPoint)
    }
    
    private func applyPhysicsAndThrow(to dice: ModelEntity, force: Float, direction: SIMD3<Float>, plane: AnchorEntity, screenPoint: CGPoint?) {
        
        dice.scale = [0.1, 0.1, 0.1] // 10cm (antes era 5cm)
        
        dice.position = [0, 0.3, -0.3]
        
        
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 1.0,  // Mais atrito (não desliza muito)
            dynamicFriction: 0.8, // Atrito ao mover
            restitution: 0.2      // Pouco quique (mais realista)
        )
        
        dice.generateCollisionShapes(recursive: true)
        
        dice.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: 0.05), // 50g (peso de um dado real)
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        if dice.collision == nil {
            let collisionShape = ShapeResource.generateBox(width: 0.1, height: 0.1, depth: 0.1)
            dice.components.set(CollisionComponent(
                shapes: [collisionShape],
                mode: .default,
                filter: .default
            ))
        }
        
        let throwDirection = SIMD3<Float>(
            direction.x * force * 0.3,  // Componente lateral
            abs(direction.y) * force * 0.4, // Componente vertical (sempre pra cima)
            direction.z * force * 0.5   // Componente frontal (pra frente)
        )
        
        dice.addForce(throwDirection, relativeTo: nil)
        
        let randomTorque = SIMD3<Float>(
            Float.random(in: -3...3),  // Antes era -10...10
            Float.random(in: -3...3),
            Float.random(in: -3...3)
        )
        dice.addTorque(randomTorque, relativeTo: nil)
        
        let raycastPoint: CGPoint
        if let screenPoint = screenPoint {
            raycastPoint = screenPoint
        } else {
            raycastPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        }
        
        var raycastResults = arView.raycast(from: raycastPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
        if raycastResults.isEmpty {
            raycastResults = arView.raycast(from: raycastPoint, allowing: .estimatedPlane, alignment: .horizontal)
        }
        
        if let raycastResult = raycastResults.first {
            let worldTransform = raycastResult.worldTransform
            
            let arAnchor = ARAnchor(transform: worldTransform)
            arView.session.add(anchor: arAnchor)
            
            let spawnAnchor = AnchorEntity(anchor: arAnchor)
            
            dice.position = [0, 0.3, 0]
            
            spawnAnchor.addChild(dice)
            arView.scene.addAnchor(spawnAnchor)
            diceEntity = dice
            
        } else {
            dice.position = [0, 0.3, -0.3]
            plane.addChild(dice)
            diceEntity = dice
        }


        Nano04DnDice.AudioManager.shared.playDiceRoll()

        startResultDetection()
    }
    
    private func throwFallbackDice(force: Float, direction: SIMD3<Float>, plane: AnchorEntity, screenPoint: CGPoint?) {
        
        let mesh = MeshResource.generateSphere(radius: 0.05) // 5cm de raio
        var material = SimpleMaterial()
        material.color = .init(tint: .systemYellow)
        material.metallic = .float(0.8)
        material.roughness = .float(0.2)
        
        let fallbackDice = ModelEntity(mesh: mesh, materials: [material])
        
        
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 1.0,
            dynamicFriction: 0.8,
            restitution: 0.2
        )
        
        fallbackDice.generateCollisionShapes(recursive: false)
        
        fallbackDice.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: 0.05),
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        if fallbackDice.collision == nil {
            let collisionShape = ShapeResource.generateSphere(radius: 0.05)
            fallbackDice.components.set(CollisionComponent(
                shapes: [collisionShape],
                mode: .default,
                filter: .default
            ))
        }
        
        let throwDirection = SIMD3<Float>(
            direction.x * force * 0.3,
            abs(direction.y) * force * 0.4,
            direction.z * force * 0.5
        )
        
        let randomTorque = SIMD3<Float>(
            Float.random(in: -3...3),
            Float.random(in: -3...3),
            Float.random(in: -3...3)
        )
        
        let raycastPoint: CGPoint
        if let screenPoint = screenPoint {
            raycastPoint = screenPoint
        } else {
            raycastPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        }
        
        var raycastResults = arView.raycast(from: raycastPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
        if raycastResults.isEmpty {
            raycastResults = arView.raycast(from: raycastPoint, allowing: .estimatedPlane, alignment: .horizontal)
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
    
    private func startResultDetection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.detectDiceResult()
        }
    }
    
    private func detectDiceResult() {
        guard let dice = diceEntity else { return }
        
        let rotation = dice.orientation
        
        let x = atan2(2 * (rotation.vector.w * rotation.vector.x + rotation.vector.y * rotation.vector.z),
                      1 - 2 * (rotation.vector.x * rotation.vector.x + rotation.vector.y * rotation.vector.y))
        let y = asin(2 * (rotation.vector.w * rotation.vector.y - rotation.vector.z * rotation.vector.x))
        let z = atan2(2 * (rotation.vector.w * rotation.vector.z + rotation.vector.x * rotation.vector.y),
                      1 - 2 * (rotation.vector.y * rotation.vector.y + rotation.vector.z * rotation.vector.z))
        let eulerAngles = SIMD3<Float>(x, y, z)
        
        let result = mapRotationToD20Face(eulerAngles: eulerAngles)
        
        DispatchQueue.main.async {
            self.diceResult = result
            self.isDiceThrown = false // Permite jogar novamente
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                dice.removeFromParent()
                self.diceEntity = nil
            }
        }
    }
    
    private func mapRotationToD20Face(eulerAngles: SIMD3<Float>) -> Int {
        
        let x = eulerAngles.x
        let y = eulerAngles.y
        let z = eulerAngles.z
        
        let combined = (x + y + z) * 100
        let normalized = abs(Int(combined)) % 20 + 1
        
        return normalized
    }
}

extension ARDiceCoordinator: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                
                DispatchQueue.main.async {
                    self.surfaceDetected = true
                }
                
                if detectedPlane == nil {
                    let anchorEntity = AnchorEntity(anchor: planeAnchor)
                    arView.scene.addAnchor(anchorEntity)
                    detectedPlane = anchorEntity
                    
                    
                    addSurfaceIndicator(to: anchorEntity, planeAnchor: planeAnchor)
                }
            }
        }
    }
    
    private func addSurfaceIndicator(to anchor: AnchorEntity, planeAnchor: ARPlaneAnchor) {
        
        let extent = planeAnchor.planeExtent
        let mesh = MeshResource.generatePlane(
            width: extent.width,
            depth: extent.height
        )
        
        var material = SimpleMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.1))
        
        let visualPlane = ModelEntity(mesh: mesh, materials: [material])
        visualPlane.position = [0, 0, 0]
        
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
        
        anchor.addChild(visualPlane)
        anchor.addChild(physicsPlane)
    }
}

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
