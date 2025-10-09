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
        if isRolling {
            webView.evaluateJavaScript("startDiceRoll();")
        } else {
            webView.evaluateJavaScript("showNumber(\(currentNumber));")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onRollComplete: onRollComplete)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        let onRollComplete: (Int) -> Void
        
        init(onRollComplete: @escaping (Int) -> Void) {
            self.onRollComplete = onRollComplete
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
                let scene, camera, renderer, icosahedron;
                let isRolling = false;
                let currentNumber = 1;
                let numberDisplay;
                
                function init() {
                    numberDisplay = document.getElementById('numberDisplay');
                    
                    scene = new THREE.Scene();
                    camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000);
                    camera.position.z = 2.2;
                    
                    renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
                    renderer.setSize(window.innerWidth, window.innerHeight);
                    renderer.setClearColor(0x000000, 0);
                    document.getElementById('container').appendChild(renderer.domElement);
                    
                    const geometry = new THREE.IcosahedronGeometry(0.9, 0);
                    const material = new THREE.MeshPhongMaterial({
                        color: 0xffffff,
                        shininess: 100,
                        specular: 0x222222,
                        transparent: true,
                        opacity: 0.3
                    });
                    
                    icosahedron = new THREE.Mesh(geometry, material);
                    // Rotação inicial mais agradável
                    icosahedron.rotation.x = Math.PI * 0.15;
                    icosahedron.rotation.y = Math.PI * 0.2;
                    scene.add(icosahedron);
                    
                    const wireframe = new THREE.WireframeGeometry(geometry);
                    const line = new THREE.LineSegments(wireframe);
                    line.material.color.setHex(0xffd700);
                    line.material.opacity = 0.8;
                    line.material.transparent = true;
                    icosahedron.add(line);
                    
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
                        icosahedron.rotation.x += 0.005;
                        icosahedron.rotation.y += 0.008;
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
                            icosahedron.rotation.x += (Math.random() - 0.5) * 0.6;
                            icosahedron.rotation.y += (Math.random() - 0.5) * 0.6;
                            icosahedron.rotation.z += (Math.random() - 0.5) * 0.6;
                            
                            if (rollTime % 100 === 0) {
                                currentNumber = Math.floor(Math.random() * 20) + 1;
                                updateNumberDisplay();
                            }
                            
                            rollTime += 50;
                            setTimeout(rollAnimation, 50);
                        } else {
                            const finalResult = Math.floor(Math.random() * 20) + 1;
                            currentNumber = finalResult;
                            updateNumberDisplay();
                            
                            if (numberDisplay) {
                                numberDisplay.style.opacity = '1';
                            }
                            
                            let smoothTime = 0;
                            const smoothDuration = 1000;
                            const initialRotX = icosahedron.rotation.x;
                            const initialRotY = icosahedron.rotation.y;
                            const initialRotZ = icosahedron.rotation.z;
                            
                            function smoothStop() {
                                smoothTime += 50;
                                const progress = Math.min(smoothTime / smoothDuration, 1);
                                const easeOut = 1 - Math.pow(1 - progress, 3);
                                
                                const targetX = Math.PI * 0.2;
                                const targetY = Math.PI * 0.3;
                                const targetZ = 0;
                                
                                icosahedron.rotation.x = initialRotX + (targetX - initialRotX) * easeOut;
                                icosahedron.rotation.y = initialRotY + (targetY - initialRotY) * easeOut;
                                icosahedron.rotation.z = initialRotZ + (targetZ - initialRotZ) * easeOut;
                                
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
