
import SwiftUI
import Combine

/// Gerencia status de assinatura - MODIFICADO: Tudo liberado (Removido RevenueCat)
@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    /// Entitlement ID (mantido para compatibilidade de nomes, se necessário)
    static let proEntitlement = "Dice and Dragons Pro"
    
    @Published var isPro: Bool = true // Sempre Pro agora
    @Published var offerings: Any? = nil
    @Published var customerInfo: Any? = nil
    @Published var isPurchasing: Bool = false
    @Published var errorMessage: String?
    @Published var showPaywall: Bool = false
    
    private init() {
        // Nada para inicializar do RevenueCat
    }
    
    /// Atualiza o status da assinatura (Simulado)
    func refreshStatus() async {
        self.isPro = true
        print("💰 Subscription status: UNLOCKED (RC Removed)")
    }
    
    /// Realiza a compra (Desativado)
    func purchase(package: Any) async {
        // Não faz nada, já é Pro
        self.isPro = true
        self.showPaywall = false
    }
    
    /// Restaura compras (Simulado)
    func restorePurchases() async {
        self.isPro = true
    }
    
    /// Verifica se o usuário pode adicionar um novo item (Sempre true agora)
    func canAddItem(currentCount: Int, limit: Int = 1) -> Bool {
        return true
    }
    
    /// Mensagem de erro padrão
    var proRequirementMessage: String {
        "Everything is unlocked!"
    }
}
