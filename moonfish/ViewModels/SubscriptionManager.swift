import SwiftUI
import StoreKit

@MainActor
@Observable
final class SubscriptionManager {
    private(set) var tier: Tier = .free
    private var listener: Task<Void, Never>?
    
    var onTierChange: ((Tier) async -> Void)?
    var isSubscribed: Bool { tier == .premium }
    
    init() {
        startListening()
    }
    
    func refresh() async {
        let hasSubscription = await checkStoreKitSubscription()
        let newTier: Tier = hasSubscription ? .premium : .free
        
        if newTier != tier {
            tier = newTier
            await onTierChange?(newTier)
        }
    }
    
    private func startListening() {
        listener = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refresh()
                }
            }
        }
    }
    
    private func checkStoreKitSubscription() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               (transaction.productID.contains("monthly") ||
                transaction.productID.contains("annual")),
               !transaction.isUpgraded {
                return true
            }
        }
        return false
    }
}
