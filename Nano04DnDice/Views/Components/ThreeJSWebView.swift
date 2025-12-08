
import SwiftUI
import WebKit

struct ThreeJSWebView: UIViewRepresentable {
    let currentNumber: Int
    let isRolling: Bool
    let diceSides: Int  // Número de lados do dado
    let onRollComplete: (Int) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
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
        // Check if dice type changed - only reload if necessary
        if context.coordinator.currentDiceSides != diceSides {
            context.coordinator.currentDiceSides = diceSides
            context.coordinator.isSceneLoaded = false
            loadThreeJSScene(webView: webView, coordinator: context.coordinator)
            return
        }
        
        // Wait for scene to be loaded before executing JavaScript
        guard context.coordinator.isSceneLoaded else {
            // Queue the action for after scene loads
            context.coordinator.pendingAction = isRolling ? .roll(currentNumber) : .show(currentNumber)
            return
        }
        
        // Execute JavaScript with error handling
        if isRolling {
            webView.evaluateJavaScript("if (typeof startDiceRoll === 'function') { startDiceRoll(\(currentNumber)); }") { result, error in
                if let error = error {
                    print("❌ Error rolling dice: \(error.localizedDescription)")
                }
            }
        } else {
            webView.evaluateJavaScript("if (typeof showNumber === 'function') { showNumber(\(currentNumber)); }") { result, error in
                if let error = error {
                    print("❌ Error showing number: \(error.localizedDescription)")
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
            // Scene loaded successfully
            isSceneLoaded = true
            
            // Execute pending action if any
            if let action = pendingAction {
                pendingAction = nil
                switch action {
                case .roll(let number):
                    webView.evaluateJavaScript("if (typeof startDiceRoll === 'function') { startDiceRoll(\(number)); }") { _, error in
                        if let error = error {
                            print("❌ Error executing pending roll: \(error.localizedDescription)")
                        }
                    }
                case .show(let number):
                    webView.evaluateJavaScript("if (typeof showNumber === 'function') { showNumber(\(number)); }") { _, error in
                        if let error = error {
                            print("❌ Error executing pending show: \(error.localizedDescription)")
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
        // Load external HTML file from Resources folder
        guard let htmlPath = Bundle.main.path(forResource: "ThreeJSScene", ofType: "html", inDirectory: "Resources") else {
            print("❌ Error: ThreeJSScene.html not found in Resources folder")
            return
        }
        
        do {
            // Read HTML template and validate placeholder exists
            var htmlContent = try String(contentsOfFile: htmlPath, encoding: .utf8)
            
            // Validate placeholder exists
            if !htmlContent.contains("{{DICE_SIDES}}") {
                print("⚠️ Warning: {{DICE_SIDES}} placeholder not found in HTML template")
            }
            
            // Replace placeholder with actual dice sides value
            htmlContent = htmlContent.replacingOccurrences(of: "{{DICE_SIDES}}", with: String(diceSides))
            
            // Load with bundle URL as baseURL for proper resource loading
            let bundleURL = Bundle.main.bundleURL
            webView.loadHTMLString(htmlContent, baseURL: bundleURL)
            
            print("✅ ThreeJS scene loaded for d\(diceSides)")
        } catch {
            print("❌ Error loading ThreeJSScene.html: \(error.localizedDescription)")
        }
    }
}
