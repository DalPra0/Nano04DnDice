
import SwiftUI
import RealityKit
import ARKit
import Combine

private enum ARConstants {
    static let scale3D: Float = 0.1
    static let collisionBoxSize: Float = 0.1
    static let fallbackSphereRadius: Float = 0.05
    static let mass: Float = 0.05
    static let staticFriction: Float = 1.0
    static let dynamicFriction: Float = 0.8
    static let restitution: Float = 0.2
    static let spawnHeight: Float = 0.3
    static let planeSize: Float = 10.0
    static let planeHeight: Float = 0.05
    static let diceRoll: TimeInterval = 3.0
    static let resultDisplay: TimeInterval = 4.0
}

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
    
    static var isARSupported: Bool {
        ARWorldTrackingConfiguration.isSupported
    }
    
    override init() {
        super.init()
        
        guard Self.isARSupported else {
            print("⚠️ AR is not supported on this device")
            return
        }
        
        setupARView()
        startPulseAnimation()
    }
    
    private func setupARView() {
        guard Self.isARSupported else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
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
    }
    
    func startSession() {
        guard Self.isARSupported else {
            print("❌ Cannot start AR session - AR not supported")
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
    }
    
    func stopSession() {
        arView.session.pause()
        resultCheckTimer?.invalidate()
        cleanup()
    }
    
    private func cleanup() {
        resultCheckTimer?.invalidate()
        resultCheckTimer = nil
        
        diceEntity?.removeFromParent()
        diceEntity = nil
        
        detectedPlane?.removeFromParent()
        detectedPlane = nil
        
        cancellables.removeAll()
        
        arView.scene.anchors.removeAll()
    }
    
    deinit {
        // Cancel all timers before cleanup to prevent memory leaks
        cancellables.removeAll()
        cleanup()
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
                    print("[AR] Warning: No ModelEntity found in D20.usdz, using fallback sphere")
                    self.throwFallbackDice(force: force, direction: direction, plane: plane, screenPoint: screenPoint)
                }
                
            } catch {
                print("[AR] Error loading D20.usdz: \(error.localizedDescription)")
                self.throwFallbackDice(force: force, direction: direction, plane: plane, screenPoint: screenPoint)
            }
            return
        } else {
            print("[AR] Error: D20.usdz not found in bundle at Resources/Models/D20.usdz")
        }
        
        throwFallbackDice(force: force, direction: direction, plane: plane, screenPoint: screenPoint)
    }
    
    private func applyPhysicsAndThrow(to dice: ModelEntity, force: Float, direction: SIMD3<Float>, plane: AnchorEntity, screenPoint: CGPoint?) {
        
        dice.scale = [ARConstants.scale3D, ARConstants.scale3D, ARConstants.scale3D]
        
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: ARConstants.staticFriction,
            dynamicFriction: ARConstants.dynamicFriction,
            restitution: ARConstants.restitution
        )
        
        dice.generateCollisionShapes(recursive: true)
        
        dice.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: ARConstants.mass),
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        if dice.collision == nil {
            let boxSize = ARConstants.collisionBoxSize
            let collisionShape = ShapeResource.generateBox(width: boxSize, height: boxSize, depth: boxSize)
            dice.components.set(CollisionComponent(
                shapes: [collisionShape],
                mode: .default,
                filter: .default
            ))
        }
        
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
            
            dice.position = [0, ARConstants.spawnHeight, 0]
            spawnAnchor.addChild(dice)
            arView.scene.addAnchor(spawnAnchor)
            diceEntity = dice
        } else {
            dice.position = [0, ARConstants.spawnHeight, -0.3]
            plane.addChild(dice)
            diceEntity = dice
        }
        
        let throwDirection = SIMD3<Float>(
            direction.x * force * 0.3,
            abs(direction.y) * force * 0.4,
            direction.z * force * 0.5
        )
        dice.addForce(throwDirection, relativeTo: nil)
        
        let randomTorque = SIMD3<Float>(
            Float.random(in: -3...3),
            Float.random(in: -3...3),
            Float.random(in: -3...3)
        )
        dice.addTorque(randomTorque, relativeTo: nil)

        Nano04DnDice.AudioManager.shared.playDiceRoll()
        startResultDetection()
    }
    
    private func throwFallbackDice(force: Float, direction: SIMD3<Float>, plane: AnchorEntity, screenPoint: CGPoint?) {
        
        let mesh = MeshResource.generateSphere(radius: ARConstants.fallbackSphereRadius)
        var material = SimpleMaterial()
        material.color = .init(tint: .systemYellow)
        material.metallic = .float(0.8)
        material.roughness = .float(0.2)
        
        let fallbackDice = ModelEntity(mesh: mesh, materials: [material])
        
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: ARConstants.staticFriction,
            dynamicFriction: ARConstants.dynamicFriction,
            restitution: ARConstants.restitution
        )
        
        fallbackDice.generateCollisionShapes(recursive: false)
        
        fallbackDice.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: ARConstants.mass),
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        if fallbackDice.collision == nil {
            let collisionShape = ShapeResource.generateSphere(radius: ARConstants.fallbackSphereRadius)
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
            fallbackDice.position = [0, ARConstants.spawnHeight, 0]
            spawnAnchor.addChild(fallbackDice)
            arView.scene.addAnchor(spawnAnchor)
            diceEntity = fallbackDice
        } else {
            fallbackDice.position = [0, ARConstants.spawnHeight, -0.3]
            plane.addChild(fallbackDice)
            diceEntity = fallbackDice
        }
        
        fallbackDice.addForce(throwDirection, relativeTo: nil)
        fallbackDice.addTorque(randomTorque, relativeTo: nil)
        
        Nano04DnDice.AudioManager.shared.playDiceRoll()
        startResultDetection()
    }
    
    private func startResultDetection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + ARConstants.diceRoll) { [weak self] in
            self?.detectDiceResult()
        }
    }
    
    private func detectDiceResult() {
        guard let dice = diceEntity else { return }
        
        // Get the dice's current orientation in world space
        let rotation = dice.orientation
        
        // Detect which face is pointing up using normal vectors
        let result = detectTopFace(orientation: rotation)
        
        DispatchQueue.main.async {
            self.diceResult = result
            self.isDiceThrown = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + ARConstants.resultDisplay) {
                dice.removeFromParent()
                self.diceEntity = nil
            }
        }
    }
    
    /// Detects which face of the D20 is pointing up using face normal vectors
    private func detectTopFace(orientation: simd_quatf) -> Int {
        // D20 (icosahedron) face normals in local space
        // Each normal corresponds to a face value (1-20)
        let faceNormals: [SIMD3<Float>] = [
            SIMD3<Float>(0, 1, 0),           // Face 1
            SIMD3<Float>(0.8944, 0.4472, 0), // Face 2
            SIMD3<Float>(0.2764, 0.4472, 0.8506), // Face 3
            SIMD3<Float>(-0.7236, 0.4472, 0.5257), // Face 4
            SIMD3<Float>(-0.7236, 0.4472, -0.5257), // Face 5
            SIMD3<Float>(0.2764, 0.4472, -0.8506), // Face 6
            SIMD3<Float>(0.7236, -0.4472, 0.5257), // Face 7
            SIMD3<Float>(-0.2764, -0.4472, 0.8506), // Face 8
            SIMD3<Float>(-0.8944, -0.4472, 0), // Face 9
            SIMD3<Float>(-0.2764, -0.4472, -0.8506), // Face 10
            SIMD3<Float>(0.7236, -0.4472, -0.5257), // Face 11
            SIMD3<Float>(0, -1, 0),          // Face 12
            SIMD3<Float>(0.5257, 0.8507, 0), // Face 13
            SIMD3<Float>(-0.5257, 0.8507, 0), // Face 14
            SIMD3<Float>(0, 0.8507, 0.5257), // Face 15
            SIMD3<Float>(0, 0.8507, -0.5257), // Face 16
            SIMD3<Float>(0, -0.8507, 0.5257), // Face 17
            SIMD3<Float>(0, -0.8507, -0.5257), // Face 18
            SIMD3<Float>(0.5257, -0.8507, 0), // Face 19
            SIMD3<Float>(-0.5257, -0.8507, 0) // Face 20
        ]
        
        // World up direction (gravity direction)
        let upDirection = SIMD3<Float>(0, 1, 0)
        
        var maxDotProduct: Float = -1.0
        var topFaceIndex = 0
        
        // Find which face normal aligns best with the up direction
        for (index, normal) in faceNormals.enumerated() {
            // Transform the face normal from local space to world space
            let worldNormal = orientation.act(normal)
            
            // Calculate dot product with up direction
            let dotProduct = simd_dot(worldNormal, upDirection)
            
            // Track the face with the highest dot product (most aligned with up)
            if dotProduct > maxDotProduct {
                maxDotProduct = dotProduct
                topFaceIndex = index
            }
        }
        
        // Return face value (1-indexed)
        return topFaceIndex + 1
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
        
        let planeShape = ShapeResource.generateBox(
            width: ARConstants.planeSize,
            height: ARConstants.planeHeight,
            depth: ARConstants.planeSize
        )
        
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: ARConstants.staticFriction,
            dynamicFriction: ARConstants.dynamicFriction,
            restitution: 0.1
        )
        
        let physicsPlane = ModelEntity()
        physicsPlane.position = [0, -0.025, 0]
        
        physicsPlane.components.set(PhysicsBodyComponent(
            massProperties: .default,
            material: physicsMaterial,
            mode: .static
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
