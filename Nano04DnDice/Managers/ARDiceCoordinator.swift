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
        print("🎬 === AR DICE COORDINATOR INICIALIZADO ===")
        print("📱 Device: \(UIDevice.current.name)")
        print("📂 Bundle: \(Bundle.main.bundlePath)")
        
        // Debug: Lista arquivos .usdz IMEDIATAMENTE
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let allFiles = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                let usdzFiles = allFiles.filter { $0.hasSuffix(".usdz") }
                print("📦 Arquivos .usdz no bundle: \(usdzFiles.count) arquivo(s)")
                if !usdzFiles.isEmpty {
                    print("✅ D20.usdz está no bundle? \(usdzFiles.contains("D20.usdz"))")
                    print("📦 Lista: \(usdzFiles)")
                } else {
                    print("❌ NENHUM arquivo .usdz encontrado no bundle!")
                }
            }
            
            // Verifica subpasta Models/
            let modelsPath = (resourcePath as NSString).appendingPathComponent("Models")
            if fileManager.fileExists(atPath: modelsPath) {
                print("✅ Pasta Models/ existe")
                if let modelFiles = try? fileManager.contentsOfDirectory(atPath: modelsPath) {
                    print("📦 Arquivos em Models/: \(modelFiles)")
                }
            } else {
                print("❌ Pasta Models/ NÃO existe")
            }
        }
        
        // Testa Bundle.main.url
        if let url = Bundle.main.url(forResource: "D20", withExtension: "usdz") {
            print("✅ Bundle.main.url ENCONTROU D20.usdz!")
            print("📍 URL: \(url)")
            print("📍 Path: \(url.path)")
            print("📍 Arquivo existe? \(FileManager.default.fileExists(atPath: url.path))")
        } else {
            print("❌ Bundle.main.url NÃO encontrou D20.usdz")
        }
        
        print("🎬 === FIM DO DEBUG INICIAL ===\n")
        
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
        print("🎥 === INICIANDO SESSÃO AR ===")
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        print("✅ Sessão AR iniciada - aguardando detecção de superfície...")
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
        print("\n🎲 === THROW DICE CHAMADO! ===")
        print("💪 Força: \(force)")
        print("🔍 Superfície detectada? \(surfaceDetected)")
        print("📍 Plane existe? \(detectedPlane != nil)")
        
        guard surfaceDetected, let plane = detectedPlane else {
            print("⚠️ Superfície não detectada ou anchor nulo")
            print("❌ Abortando arremesso!")
            return
        }
        
        isDiceThrown = true
        diceResult = nil
        
        print("🔍 === INICIANDO CARGA DO D20.USDZ ===")
        
        // DEBUG: Verifica bundle resources
        if let resourcePath = Bundle.main.resourcePath {
            print("📂 Bundle path: \(resourcePath)")
            let fileManager = FileManager.default
            
            // Lista TUDO no bundle
            if let allFiles = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                let usdzFiles = allFiles.filter { $0.hasSuffix(".usdz") }
                print("📦 Total de arquivos no bundle: \(allFiles.count)")
                print("📦 Arquivos .usdz encontrados: \(usdzFiles)")
            }
            
            // Verifica subpastas
            let modelsPath = (resourcePath as NSString).appendingPathComponent("Models")
            if fileManager.fileExists(atPath: modelsPath) {
                print("✅ Pasta Models existe em: \(modelsPath)")
                if let modelFiles = try? fileManager.contentsOfDirectory(atPath: modelsPath) {
                    print("📦 Arquivos em Models/: \(modelFiles)")
                }
            } else {
                print("❌ Pasta Models NÃO existe!")
            }
            
            // Busca recursiva por D20.usdz
            if let enumerator = fileManager.enumerator(atPath: resourcePath) {
                let d20Files = enumerator.allObjects.compactMap { $0 as? String }.filter { $0.contains("D20") }
                print("🔍 Arquivos com 'D20' no nome: \(d20Files)")
            }
        }
        
        // TENTATIVA 1: Bundle.main.url (MAIS CONFIÁVEL)
        print("\n🔄 Tentativa 1: Bundle.main.url...")
        if let url = Bundle.main.url(forResource: "D20", withExtension: "usdz") {
            print("✅ URL encontrada: \(url)")
            print("📍 Path absoluto: \(url.path)")
            print("📍 Arquivo existe? \(FileManager.default.fileExists(atPath: url.path))")
            
            // CARREGAMENTO SÍNCRONO (funciona melhor no RealityKit!)
            print("⏳ Carregando modelo...")
            do {
                let loadedEntity = try Entity.load(contentsOf: url)
                print("✅ Entity carregado! Tipo: \(type(of: loadedEntity))")
                
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
                    print("✅ ModelEntity encontrado!")
                    self.applyPhysicsAndThrow(to: finalDice, force: force, plane: plane)
                } else {
                    print("❌ Nenhum ModelEntity com geometria encontrado!")
                    print("🔍 Hierarquia: \(loadedEntity)")
                    self.throwFallbackDice(force: force, plane: plane)
                }
                
            } catch {
                print("❌ ERRO ao carregar: \(error)")
                print("❌ Descrição: \(error.localizedDescription)")
                self.throwFallbackDice(force: force, plane: plane)
            }
            return
        }
        
        // Se chegou aqui, Bundle.main.url não encontrou
        print("❌ Bundle.main.url falhou!")
        print("❌ TODAS as tentativas falharam!")
        throwFallbackDice(force: force, plane: plane)
    }
    
    // MARK: - Helper: Aplicar física e jogar
    private func applyPhysicsAndThrow(to dice: ModelEntity, force: Float, plane: AnchorEntity) {
        print("\n🎲 Configurando dado...")
        print("📏 Escala original: \(dice.scale)")
        
        // Configura escala - MAIOR para visualizar melhor!
        dice.scale = [0.1, 0.1, 0.1] // 10cm (antes era 5cm)
        
        // Posição inicial: ACIMA da superfície detectada, NA FRENTE da câmera
        // Y = 0.3 (30cm acima do plano)
        // Z = -0.3 (30cm na frente da câmera, mais próximo)
        dice.position = [0, 0.3, -0.3]
        
        print("📍 Posição do dado: \(dice.position)")
        
        // FÍSICA MELHORADA - collision mais precisa
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 1.0,  // Mais atrito (não desliza muito)
            dynamicFriction: 0.8, // Atrito ao mover
            restitution: 0.2      // Pouco quique (mais realista)
        )
        
        // Collision shape: BOX (mais preciso que esfera pro D20)
        let collisionShape = ShapeResource.generateBox(
            width: 0.1,   // 10cm
            height: 0.1,  // 10cm  
            depth: 0.1    // 10cm
        )
        
        dice.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: 0.05), // 50g (peso de um dado real)
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        dice.components.set(CollisionComponent(
            shapes: [collisionShape],
            mode: .default,
            filter: .default
        ))
        
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
        
        print("💫 Força aplicada: \(throwDirection)")
        print("🌀 Torque aplicado: \(randomTorque)")
        
        // Adiciona à cena
        plane.addChild(dice)
        diceEntity = dice
        
        print("✅ Dado adicionado à cena!")
        print("👁️ Olhe na câmera AR agora!")
        
        // Som de arremesso
        Nano04DnDice.AudioManager.shared.playDiceRoll()
        
        // Inicia detecção de resultado
        startResultDetection()
    }
    
    // MARK: - Helper: Dado Fallback (esfera dourada)
    private func throwFallbackDice(force: Float, plane: AnchorEntity) {
        print("\n🎲 Usando dado FALLBACK (esfera dourada)")
        
        // Cria um dado fallback (esfera simples)
        let mesh = MeshResource.generateSphere(radius: 0.05) // 5cm de raio
        var material = SimpleMaterial()
        material.color = .init(tint: .systemYellow)
        material.metallic = .float(0.8)
        material.roughness = .float(0.2)
        
        let fallbackDice = ModelEntity(mesh: mesh, materials: [material])
        fallbackDice.position = [0, 0.3, -0.3] // Mesma posição do dado real
        fallbackDice.scale = [1.0, 1.0, 1.0] // Escala normal
        
        print("📍 Posição fallback: \(fallbackDice.position)")
        print("📏 Escala fallback: \(fallbackDice.scale)")
        
        // Adiciona física - MESMA configuração do dado real
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 1.0,
            dynamicFriction: 0.8,
            restitution: 0.2
        )
        
        let collisionShape = ShapeResource.generateSphere(radius: 0.05)
        
        fallbackDice.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: 0.05),
            material: physicsMaterial,
            mode: .dynamic
        ))
        
        fallbackDice.components.set(CollisionComponent(
            shapes: [collisionShape],
            mode: .default,
            filter: .default
        ))
        
        // Aplica força - MESMA do dado real
        let throwDirection = SIMD3<Float>(
            Float.random(in: -0.2...0.2),
            -force * 0.5,
            Float.random(in: -0.2...0.2)
        )
        fallbackDice.addForce(throwDirection, relativeTo: nil)
        
        let randomTorque = SIMD3<Float>(
            Float.random(in: -3...3),
            Float.random(in: -3...3),
            Float.random(in: -3...3)
        )
        fallbackDice.addTorque(randomTorque, relativeTo: nil)
        
        print("💫 Força fallback: \(throwDirection)")
        print("🌀 Torque fallback: \(randomTorque)")
        
        plane.addChild(fallbackDice)
        diceEntity = fallbackDice
        
        print("✅ Esfera dourada adicionada!")
        print("👁️ Olhe na câmera AR agora!")
        
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
                print("🎯 === SUPERFÍCIE DETECTADA! ===")
                print("📏 Tamanho: \(planeAnchor.planeExtent.width)m x \(planeAnchor.planeExtent.height)m")
                print("📍 Posição: \(planeAnchor.transform)")
                
                DispatchQueue.main.async {
                    self.surfaceDetected = true
                    print("✅ surfaceDetected = true")
                }
                
                // Cria anchor entity na superfície detectada
                if detectedPlane == nil {
                    let anchorEntity = AnchorEntity(anchor: planeAnchor)
                    arView.scene.addAnchor(anchorEntity)
                    detectedPlane = anchorEntity
                    
                    print("✅ AnchorEntity criado e adicionado à cena")
                    print("👆 Agora você pode ARRASTAR o dado pra cima!")
                    
                    // Adiciona um plano visual sutil
                    addSurfaceIndicator(to: anchorEntity, planeAnchor: planeAnchor)
                }
            }
        }
    }
    
    // MARK: - Surface Indicator
    private func addSurfaceIndicator(to anchor: AnchorEntity, planeAnchor: ARPlaneAnchor) {
        let extent = planeAnchor.planeExtent
        
        print("🏗️ Criando plano com física...")
        print("📏 Dimensões: \(extent.width)m x \(extent.height)m")
        
        // Mesh visual
        let mesh = MeshResource.generatePlane(
            width: extent.width,
            depth: extent.height
        )
        
        var material = SimpleMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.1))
        
        let planeEntity = ModelEntity(mesh: mesh, materials: [material])
        planeEntity.position = [0, 0, 0] // Centralizado no anchor
        
        // ⚡ ADICIONA FÍSICA AO PLANO (ESTÁTICO)
        let planeShape = ShapeResource.generateBox(
            width: extent.width,
            height: 0.01, // 1cm de espessura
            depth: extent.height
        )
        
        planeEntity.components.set(PhysicsBodyComponent(
            massProperties: .default,
            material: nil,
            mode: .static // ESTÁTICO = não se move, mas colide!
        ))
        
        planeEntity.components.set(CollisionComponent(
            shapes: [planeShape],
            mode: .default,
            filter: .default
        ))
        
        print("✅ Plano com física criado! (modo: static)")
        
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
