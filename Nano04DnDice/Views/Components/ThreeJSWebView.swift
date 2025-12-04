
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
        if context.coordinator.currentDiceSides != diceSides {
            context.coordinator.currentDiceSides = diceSides
            loadThreeJSScene(webView: webView)
            return
        }
        
        if isRolling {
            webView.evaluateJavaScript("startDiceRoll(\(currentNumber));")
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
        // Load external HTML file from Resources folder
        guard let htmlPath = Bundle.main.path(forResource: "ThreeJSScene", ofType: "html", inDirectory: "Resources") else {
            print("Error: ThreeJSScene.html not found in Resources folder")
            return
        }
        
        do {
            // Read HTML template and inject dice sides parameter
            var htmlContent = try String(contentsOfFile: htmlPath, encoding: .utf8)
            htmlContent = htmlContent.replacingOccurrences(of: "{{DICE_SIDES}}", with: String(diceSides))
            
            // Load with bundle URL as baseURL for proper resource loading
            let bundleURL = Bundle.main.bundleURL
            webView.loadHTMLString(htmlContent, baseURL: bundleURL)
        } catch {
            print("Error loading ThreeJSScene.html: \(error)")
        }
    }
}
