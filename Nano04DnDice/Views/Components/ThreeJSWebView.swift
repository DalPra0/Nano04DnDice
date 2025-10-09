//
//  ThreeJSWebView.swift
//  Nano04DnDice
//
//  WebView com Three.js para renderizar dado 3D
//

import SwiftUI
import WebKit

struct ThreeJSWebView: UIViewRepresentable {
    let currentNumber: Int
    let isRolling: Bool
    let diceSides: Int  // Número de lados do dado
    let onRollComplete: (Int) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        
        let contentController = webView.configuration.userContentController
        contentController.add(context.coordinator, name: "diceRollComplete")
        
        loadThreeJSScene(webView: webView)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Se mudou o tipo de dado, recarrega a cena
        if context.coordinator.currentDiceSides != diceSides {
            context.coordinator.currentDiceSides = diceSides
            loadThreeJSScene(webView: webView)
            return
        }
        
        if isRolling {
            webView.evaluateJavaScript("startDiceRoll();")
        } else {
            webView.evaluateJavaScript("showNumber(\(currentNumber));")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onRollComplete: onRollComplete, diceSides: diceSides)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        let onRollComplete: (Int) -> Void
        var currentDiceSides: Int
        
        init(onRollComplete: @escaping (Int) -> Void, diceSides: Int) {
            self.onRollComplete = onRollComplete
            self.currentDiceSides = diceSides
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "diceRollComplete", let result = message.body as? Int {
                DispatchQueue.main.async {
                    self.onRollComplete(result)
                }
            }
        }
    }
    
    func loadThreeJSScene(webView: WKWebView) {
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background: transparent;
                    overflow: hidden;
                    font-family: Arial, sans-serif;
                }
                #container {
                    width: 100vw;
                    height: 100vh;
                    background: transparent;
                    position: relative;
                }
                #numberDisplay {
                    position: absolute;
                    top: 50%;
                    left: 50%;
                    transform: translate(-50%, -50%);
                    color: #000;
                    font-size: 20vw;
                    font-weight: bold;
                    text-shadow: 2px 2px 4px rgba(255,255,255,0.8);
                    z-index: 10;
                    pointer-events: none;
                }
            </style>
        </head>
        <body>
            <div id="container">
                <div id="numberDisplay">1</div>
            </div>
            
            <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
            <script>
                let scene, camera, renderer, dice;
                let isRolling = false;
                let currentNumber = 1;
                let numberDisplay;
                const diceSides = \(diceSides);
                
                function getDiceGeometry(sides) {
                    switch(sides) {
                        case 4:  // Tetrahedron (D4)
                            return new THREE.TetrahedronGeometry(1.0, 0);
                        case 6:  // Box (D6)
                            return new THREE.BoxGeometry(1.4, 1.4, 1.4);
                        case 8:  // Octahedron (D8)
                            return new THREE.OctahedronGeometry(1.0, 0);
                        case 10: // D10 - duas pirâmides pentagonais unidas (bipyramid)
                            const geometry10 = new THREE.BufferGeometry();
                            const vertices10 = [];
                            const r = 0.6;  // raio do pentágono
                            const h = 1.0;  // altura de cada pirâmide
                            
                            // Vértice superior (índice 0)
                            vertices10.push(0, h, 0);
                            
                            // Pentágono no meio - 5 vértices (índices 1-5)
                            for (let i = 0; i < 5; i++) {
                                const angle = (i * Math.PI * 2) / 5;
                                vertices10.push(
                                    r * Math.cos(angle),
                                    0,
                                    r * Math.sin(angle)
                                );
                            }
                            
                            // Vértice inferior (índice 6)
                            vertices10.push(0, -h, 0);
                            
                            const indices10 = [];
                            
                            // 5 faces da pirâmide SUPERIOR
                            for (let i = 0; i < 5; i++) {
                                const curr = i + 1;
                                const next = ((i + 1) % 5) + 1;
                                indices10.push(0, curr, next);
                            }
                            
                            // 5 faces da pirâmide INFERIOR
                            for (let i = 0; i < 5; i++) {
                                const curr = i + 1;
                                const next = ((i + 1) % 5) + 1;
                                indices10.push(6, next, curr); // ordem invertida pra normal correta
                            }
                            
                            geometry10.setIndex(indices10);
                            geometry10.setAttribute('position', new THREE.Float32BufferAttribute(vertices10, 3));
                            geometry10.computeVertexNormals();
                            return geometry10;
                            
                        case 12: // Dodecahedron (D12) - geometria nativa
                            return new THREE.DodecahedronGeometry(0.85, 0);
                        case 20: // Icosahedron (D20)
                            return new THREE.IcosahedronGeometry(0.9, 0);
                        default: // Custom - usa icosahedron
                            return new THREE.IcosahedronGeometry(0.9, 0);
                    }
                }
                
                function init() {
                    numberDisplay = document.getElementById('numberDisplay');
                    
                    scene = new THREE.Scene();
                    camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000);
                    camera.position.z = 2.2;
                    
                    renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
                    renderer.setSize(window.innerWidth, window.innerHeight);
                    renderer.setClearColor(0x000000, 0);
                    document.getElementById('container').appendChild(renderer.domElement);
                    
                    const geometry = getDiceGeometry(diceSides);
                    const material = new THREE.MeshPhongMaterial({
                        color: 0xffffff,
                        shininess: 100,
                        specular: 0x222222,
                        transparent: true,
                        opacity: 0.3
                    });
                    
                    dice = new THREE.Mesh(geometry, material);
                    // Rotação inicial mais agradável
                    dice.rotation.x = Math.PI * 0.15;
                    dice.rotation.y = Math.PI * 0.2;
                    scene.add(dice);
                    
                    const wireframe = new THREE.WireframeGeometry(geometry);
                    const line = new THREE.LineSegments(wireframe);
                    line.material.color.setHex(0xffd700);
                    line.material.opacity = 0.8;
                    line.material.transparent = true;
                    dice.add(line);
                    
                    const ambientLight = new THREE.AmbientLight(0x404040, 0.8);
                    scene.add(ambientLight);
                    
                    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.6);
                    directionalLight.position.set(1, 1, 1);
                    scene.add(directionalLight);
                    
                    const pointLight = new THREE.PointLight(0xffd700, 0.4);
                    pointLight.position.set(-1, -1, 1);
                    scene.add(pointLight);
                    
                    updateNumberDisplay();
                    animate();
                }
                
                function updateNumberDisplay() {
                    if (numberDisplay) {
                        numberDisplay.textContent = currentNumber.toString();
                        numberDisplay.style.transform = 'translate(-50%, -50%) scale(1.2)';
                        setTimeout(() => {
                            numberDisplay.style.transform = 'translate(-50%, -50%) scale(1)';
                        }, 150);
                    }
                }
                
                function animate() {
                    requestAnimationFrame(animate);
                    
                    if (!isRolling) {
                        dice.rotation.x += 0.005;
                        dice.rotation.y += 0.008;
                    }
                    
                    renderer.render(scene, camera);
                }
                
                function startDiceRoll() {
                    if (isRolling) return;
                    
                    isRolling = true;
                    let rollTime = 0;
                    const rollDuration = 3000;
                    
                    if (numberDisplay) {
                        numberDisplay.style.opacity = '0.3';
                    }
                    
                    function rollAnimation() {
                        if (rollTime < rollDuration) {
                            dice.rotation.x += (Math.random() - 0.5) * 0.6;
                            dice.rotation.y += (Math.random() - 0.5) * 0.6;
                            dice.rotation.z += (Math.random() - 0.5) * 0.6;
                            
                            if (rollTime % 100 === 0) {
                                currentNumber = Math.floor(Math.random() * diceSides) + 1;
                                updateNumberDisplay();
                            }
                            
                            rollTime += 50;
                            setTimeout(rollAnimation, 50);
                        } else {
                            const finalResult = Math.floor(Math.random() * diceSides) + 1;
                            currentNumber = finalResult;
                            updateNumberDisplay();
                            
                            if (numberDisplay) {
                                numberDisplay.style.opacity = '1';
                            }
                            
                            let smoothTime = 0;
                            const smoothDuration = 1000;
                            const initialRotX = dice.rotation.x;
                            const initialRotY = dice.rotation.y;
                            const initialRotZ = dice.rotation.z;
                            
                            function smoothStop() {
                                smoothTime += 50;
                                const progress = Math.min(smoothTime / smoothDuration, 1);
                                const easeOut = 1 - Math.pow(1 - progress, 3);
                                
                                const targetX = Math.PI * 0.2;
                                const targetY = Math.PI * 0.3;
                                const targetZ = 0;
                                
                                dice.rotation.x = initialRotX + (targetX - initialRotX) * easeOut;
                                dice.rotation.y = initialRotY + (targetY - initialRotY) * easeOut;
                                dice.rotation.z = initialRotZ + (targetZ - initialRotZ) * easeOut;
                                
                                if (progress < 1) {
                                    setTimeout(smoothStop, 50);
                                } else {
                                    isRolling = false;
                                    window.webkit.messageHandlers.diceRollComplete.postMessage(finalResult);
                                }
                            }
                            
                            smoothStop();
                        }
                    }
                    
                    rollAnimation();
                }
                
                function showNumber(number) {
                    currentNumber = number;
                    updateNumberDisplay();
                }
                
                init();
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
