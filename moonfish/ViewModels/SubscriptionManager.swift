import SwiftUI
import StoreKit

@MainActor
@Observable
final class SubscriptionManager {
    private(set) var tier: Tier = .free
    private let client = NetworkClient()
    private var listener: Task<Void, Never>?
    
    init() {
        startListening()
    }
    
    func refresh() async {
        let hasSubscription = await checkStoreKitSubscription()
        let newTier: Tier = hasSubscription ? .premium : .free
        
        if newTier != tier {
            tier = newTier
            do {
                let updateRequest = SubscriptionUpdateRequest(tier: newTier)
                try await client.updateSubscription(from: updateRequest)
            } catch {
               fatalError("Unable to update subscription")
            }
        }
    }
    
    private func startListening() {
        listener = Task {
            for await result in Transaction.updates {
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
