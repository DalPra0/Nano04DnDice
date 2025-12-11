
import SwiftUI
import WebKit

struct ThreeJSWebView: UIViewRepresentable {
    let currentNumber: Int
    let isRolling: Bool
    let diceSides: Int  // Número de lados do dado
    let onRollComplete: (Int) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        print("🎲 ThreeJSWebView: makeUIView called with diceSides=\(diceSides)")
        let configuration = WKWebViewConfiguration()
        let contentController = configuration.userContentController
        contentController.add(context.coordinator, name: "diceRollComplete")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        
        loadThreeJSScene(webView: webView, coordinator: context.coordinator)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("🎲 ThreeJSWebView: updateUIView - diceSides=\(diceSides), isRolling=\(isRolling), currentNumber=\(currentNumber)")
        
        if context.coordinator.currentDiceSides != diceSides {
            print("🎲 Dice type changed from d\(context.coordinator.currentDiceSides) to d\(diceSides) - reloading scene")
            context.coordinator.currentDiceSides = diceSides
            context.coordinator.isSceneLoaded = false
            loadThreeJSScene(webView: webView, coordinator: context.coordinator)
            return
        }
        
        guard context.coordinator.isSceneLoaded else {
            print("⚠️ Scene not loaded yet - queueing action")
            context.coordinator.pendingAction = isRolling ? .roll(currentNumber) : .show(currentNumber)
            return
        }
        
        if isRolling {
            print("🎲 Executing roll to \(currentNumber)")
            webView.evaluateJavaScript("if (typeof startDiceRoll === 'function') { startDiceRoll(\(currentNumber)); }") { result, error in
                if let error = error {
                    print("❌ Error rolling dice: \(error.localizedDescription)")
                } else {
                    print("✅ Roll command sent successfully")
                }
            }
        } else {
            print("🎲 Showing number \(currentNumber)")
            webView.evaluateJavaScript("if (typeof showNumber === 'function') { showNumber(\(currentNumber)); }") { result, error in
                if let error = error {
                    print("❌ Error showing number: \(error.localizedDescription)")
                } else {
                    print("✅ Show number command sent successfully")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onRollComplete: onRollComplete, diceSides: diceSides)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        enum PendingAction {
            case roll(Int)
            case show(Int)
        }
        
        let onRollComplete: (Int) -> Void
        var currentDiceSides: Int
        var isSceneLoaded = false
        var pendingAction: PendingAction?
        weak var webView: WKWebView?
        
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
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView scene loaded successfully")
            isSceneLoaded = true
            
            if let action = pendingAction {
                print("🔄 Executing pending action: \(action)")
                pendingAction = nil
                switch action {
                case .roll(let number):
                    webView.evaluateJavaScript("if (typeof startDiceRoll === 'function') { startDiceRoll(\(number)); }") { _, error in
                        if let error = error {
                            print("❌ Error executing pending roll: \(error.localizedDescription)")
                        } else {
                            print("✅ Pending roll executed")
                        }
                    }
                case .show(let number):
                    webView.evaluateJavaScript("if (typeof showNumber === 'function') { showNumber(\(number)); }") { _, error in
                        if let error = error {
                            print("❌ Error executing pending show: \(error.localizedDescription)")
                        } else {
                            print("✅ Pending show executed")
                        }
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView navigation failed: \(error.localizedDescription)")
            isSceneLoaded = false
        }
    }
    
    func loadThreeJSScene(webView: WKWebView, coordinator: Coordinator) {
        guard let htmlPath = Bundle.main.path(forResource: "ThreeJSScene", ofType: "html", inDirectory: "Resources") else {
            print("❌❌❌ CRITICAL ERROR: ThreeJSScene.html not found in Resources folder!")
            print("📁 Searched path: Resources/ThreeJSScene.html")
            
            let fallbackHTML = """
            <!DOCTYPE html>
            <html>
            <body style="margin:0;background:transparent;display:flex;align-items:center;justify-content:center;">
                <div style="color:white;font-size:96px;font-weight:bold;text-shadow:0 0 20px rgba(255,255,255,0.5);" id="result">\(diceSides)</div>
                <script>
                function startDiceRoll(num) { 
                    document.getElementById('result').innerText = num;
                    window.webkit.messageHandlers.diceRollComplete.postMessage(num);
                }
                function showNumber(num) { document.getElementById('result').innerText = num; }
                </script>
            </body>
            </html>
            """
            webView.loadHTMLString(fallbackHTML, baseURL: nil)
            coordinator.isSceneLoaded = true
            return
        }
        
        do {
            var htmlContent = try String(contentsOfFile: htmlPath, encoding: .utf8)
            
            if !htmlContent.contains("{{DICE_SIDES}}") {
                print("⚠️ WARNING: {{DICE_SIDES}} placeholder not found in HTML template")
                print("🔧 Attempting alternative replacement...")
                htmlContent = htmlContent.replacingOccurrences(
                    of: "let diceSides = 20;",
                    with: "let diceSides = \(diceSides);"
                )
            } else {
                htmlContent = htmlContent.replacingOccurrences(of: "{{DICE_SIDES}}", with: String(diceSides))
            }
            
            let bundleURL = Bundle.main.bundleURL
            webView.loadHTMLString(htmlContent, baseURL: bundleURL)
            
            print("✅ ThreeJS scene loaded successfully for d\(diceSides)")
        } catch {
            print("❌❌❌ CRITICAL ERROR loading ThreeJSScene.html: \(error.localizedDescription)")
            print("🚫 Falling back to simple display")
        }
    }
}
