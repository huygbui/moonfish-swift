import StoreKit

@MainActor
@Observable
final class SubscriptionManager {
    private(set) var tier: Tier = .free
    private let client = NetworkClient()
    private var listener: Task<Void, Never>? = nil
    
    func start() {
        listener = Task { [weak self] in
            guard let self else { return }
            await refresh()
            for await verificationResult in Transaction.updates {
                await self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }
        
        if let _ = transaction.revocationDate {
            await updateTier(.free)
        } else if let expirationDate = transaction.expirationDate, expirationDate < Date() {
            await updateTier(.free)
        } else if transaction.isUpgraded {
            await transaction.finish()
            return
        } else if (transaction.productID.contains("monthly") ||
                   transaction.productID.contains("annual")) {
            await updateTier(.premium)
        }
        
        await transaction.finish()
    }
    
    func refresh() async {
        let newTier = await checkStoreKitSubscription()
        if newTier != tier { await updateTier(newTier) }
    }
    
    private func checkStoreKitSubscription() async -> Tier {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               (transaction.productID.contains("monthly") ||
                transaction.productID.contains("annual")),
               !transaction.isUpgraded {
                return .premium
            }
        }
        return .free
    }
    
    private func updateTier(_ newTier: Tier) async {
        do {
            let updateRequest = SubscriptionUpdateRequest(tier: newTier)
            try await client.updateSubscription(from: updateRequest)
            tier = newTier
        } catch {
            fatalError("Unable to update subscription")
        }
    }
}
