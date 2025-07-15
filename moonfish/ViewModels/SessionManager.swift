import SwiftUI
import SwiftData



@MainActor
@Observable
final class SessionManager {
    // Managers
    private let auth = AuthManager()
    private let subscription = SubscriptionManager()
    private let usageLimits = UsageLimitsManager()
    
    // Expose state for backward compatibility
    var isAuthenticated: Bool { auth.isAuthenticated }
    var subscriptionTier: Tier { subscription.tier }
    var limits: Limits { usageLimits.limits }
    var isSubscribed: Bool { subscription.isSubscribed }
    var email: String? { auth.email }
    var currentToken: String? { auth.currentToken }
    
    init() {
        // If already authenticated, refresh everything
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
    
    func signOut(context: ModelContext) {
        // Clear local data
        do {
            try context.delete(model: Podcast.self)
            try context.save()
        } catch {
            print("Failed to clear local database on logout: \(error)")
        }
        
        // Sign out
        auth.signOut()
        
        // Reset to defaults
        Task {
            await subscription.refresh()
            await usageLimits.refreshLimits(tier: .free, token: nil)
        }
    }
    
    func refreshSubscriptionStatus() async {
        guard isAuthenticated else { return }
        
        await subscription.refresh()
        await usageLimits.refreshLimits(tier: subscription.tier, token: currentToken)
    }
    
    // Delegate usage checks to UsageLimitsManager
    func canCreate(_ type: ContentType, in context: ModelContext) -> Bool {
        guard isAuthenticated else { return false }
        return usageLimits.canCreate(type, in: context)
    }
    
    func canCreateEpisode(length: EpisodeLength, in context: ModelContext) -> Bool {
        guard isAuthenticated else { return false }
        return usageLimits.canCreateEpisode(length: length, in: context)
    }
    
    func usageText(for type: ContentType, in context: ModelContext) -> String {
        guard isAuthenticated else { return "Loading..." }
        return usageLimits.usageText(for: type, in: context)
    }
}

// MARK: - Supporting Types (unchanged)
enum ContentType {
    case podcast
    case episode
    case extendedEpisode
}

struct Limits {
    let maxPodcasts: Int
    let maxDailyEpisodes: Int
    let maxDailyExtendedEpisodes: Int
    
    static let free = Limits(
        maxPodcasts: 3,
        maxDailyEpisodes: 3,
        maxDailyExtendedEpisodes: 1
    )
    
    static let premium = Limits(
        maxPodcasts: 12,
        maxDailyEpisodes: 12,
        maxDailyExtendedEpisodes: 3
    )
    
    static let loading = Limits(
        maxPodcasts: 0,
        maxDailyEpisodes: 0,
        maxDailyExtendedEpisodes: 0
    )
}
