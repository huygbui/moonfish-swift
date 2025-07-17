import SwiftUI
import SwiftData



@MainActor
@Observable
final class SessionManager {
    private let auth = AuthManager()
    private let subscription = SubscriptionManager()
    private let usage = UsageManager()
    
    var isAuthenticated: Bool { auth.isAuthenticated }
    var subscriptionTier: Tier { subscription.tier }
    var limits: Limits { usage.limits }
    var isSubscribed: Bool { subscription.isSubscribed }
    
    init() {
        subscription.onTierChange = { [weak self] newTier in
            guard let self else { return }
            await self.usage.refreshLimits(tier: newTier)
        }
        
        if auth.isAuthenticated {
            Task {
                await refreshSubscriptionStatus()
            }
        }
    }
    
    func signIn(appleId: String, email: String?, fullName: String?) async throws {
        try await auth.signIn(appleId: appleId, email: email, fullName: fullName)
        await refreshSubscriptionStatus()
    }
    
    func signOut(context: ModelContext) throws {
        try context.delete(model: Podcast.self)
        try context.save()
        try auth.signOut()
    }
    
    func refreshSubscriptionStatus() async {
        guard isAuthenticated else { return }
        await subscription.refresh()
        await usage.refreshLimits(tier: subscription.tier)
    }
    
    func canCreate(_ type: ContentType, in context: ModelContext) -> Bool {
        isAuthenticated && usage.canCreate(type, in: context)
    }
    
    func canCreateEpisode(length: EpisodeLength, in context: ModelContext) -> Bool {
        isAuthenticated && usage.canCreateEpisode(length: length, in: context)
    }
}
