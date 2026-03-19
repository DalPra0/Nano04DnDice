
import SwiftUI
import RevenueCat
import RevenueCatUI
import Combine

/// Cérebro da monetização: gerencia status de assinatura e ofertas
@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    /// Entitlement ID configurado no dashboard do RevenueCat
    static let proEntitlement = "Dice and Dragons Pro"
    
    @Published var isPro: Bool = false
    @Published var offerings: Offerings?
    @Published var customerInfo: CustomerInfo?
    @Published var isPurchasing: Bool = false
    @Published var errorMessage: String?
    @Published var showPaywall: Bool = false
    
    private init() {
        // Observa mudanças na informação do usuário (assinatura, compras)
        Purchases.shared.delegate = PurchasesDelegateProxy.shared
        
        // Atualiza o estado inicial
        Task {
            await refreshStatus()
        }
    }
    
    /// Atualiza o status da assinatura e ofertas disponíveis
    func refreshStatus() async {
        do {
            self.customerInfo = try await Purchases.shared.customerInfo()
            self.isPro = customerInfo?.entitlements[Self.proEntitlement]?.isActive ?? false
            
            self.offerings = try await Purchases.shared.offerings()
            
            print("💰 Subscription status: \(isPro ? "PRO" : "FREE")")
        } catch {
            print("❌ Error fetching RC status: \(error.localizedDescription)")
        }
    }
    
    /// Realiza a compra de um pacote (Monthly, Yearly, Lifetime)
    func purchase(_ package: Package) async {
        isPurchasing = true
        errorMessage = nil
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                self.isPro = result.customerInfo.entitlements[Self.proEntitlement]?.isActive ?? false
                self.showPaywall = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isPurchasing = false
    }
    
    /// Restaura compras anteriores (ex: se o usuário trocou de aparelho)
    func restorePurchases() async {
        isPurchasing = true
        do {
            let info = try await Purchases.shared.restorePurchases()
            self.isPro = info.entitlements[Self.proEntitlement]?.isActive ?? false
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }
    
    /// Verifica se o usuário pode adicionar um novo item baseado no limite da conta free
    func canAddItem(currentCount: Int, limit: Int = 1) -> Bool {
        if isPro { return true }
        return currentCount < limit
    }
    
    /// Mensagem de erro padrão para recursos bloqueados
    var proRequirementMessage: String {
        "This feature requires Dice and Dragons Pro. Upgrade to unlock unlimited access!"
    }
    
    /// Helper para delegar callbacks globais do RevenueCat
    class PurchasesDelegateProxy: NSObject, PurchasesDelegate {
        static let shared = PurchasesDelegateProxy()
        
        func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
            Task { @MainActor in
                SubscriptionManager.shared.customerInfo = customerInfo
                SubscriptionManager.shared.isPro = customerInfo.entitlements[SubscriptionManager.proEntitlement]?.isActive ?? false
            }
        }
    }
}
