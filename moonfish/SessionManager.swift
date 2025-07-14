//
//  SessionManager.swift
//  moonfish
//
//  Unified session management for authentication and subscriptions
//

import SwiftUI
import SwiftData
import StoreKit

@MainActor
@Observable
final class SessionManager {
    // MARK: - Published State
    private(set) var isAuthenticated = false
    private(set) var isLoading = false
    private(set) var subscriptionTier: SubscriptionTier = .free
    private(set) var limits = Limits.loading
    
    // MARK: - Computed Properties
    var isSubscribed: Bool { subscriptionTier == .premium }
    var email: String? { keychain.retrieve(key: Keys.email) }
    
    var currentToken: String? {
#if DEBUG
        return APIConfig.shared.apiToken
#else
        return keychain.retrieve(key: Keys.token)
#endif
    }
    
    // MARK: - Private Properties
    private let client = BackendClient()
    private let keychain = KeychainHelper.self
    private var subscriptionListener: Task<Void, Never>?
    
    private enum Keys {
        static let token = "auth-token"
        static let email = "user-email"
    }
    
    // MARK: - Initialization
    init() {
        checkAuthenticationStatus()
        startSubscriptionListener()
    }
    
    // MARK: - Public Methods
    func signIn(appleId: String, email: String?, fullName: String?) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let request = AppleSignInRequest(
            appleId: appleId,
            email: email,
            fullName: fullName
        )
        
        let response = try await client.getAuthToken(for: request)
        
        // Store credentials
        storeCredentials(token: response.token.accessToken, email: email)
        
        // Refresh subscription status
        await refreshSubscriptionStatus()
    }
    
    func signOut(context: ModelContext) {
        do {
            try context.delete(model: Podcast.self)
            try context.save()
        } catch {
            print("Failed to clear local database on logout: \(error)")
        }
        
        clearCredentials()
        resetToDefaults()
    }
    
    func refreshSubscriptionStatus() async {
        guard isAuthenticated else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        // Check StoreKit for subscription status
        let hasSubscription = await checkStoreKitSubscription()
        subscriptionTier = hasSubscription ? .premium : .free
        
        // Fetch limits from backend
        await fetchLimits()
    }
    
    // MARK: - Usage Checks
    func canCreate(_ type: ContentType, in context: ModelContext) -> Bool {
        guard !isLoading, isAuthenticated else { return false }
        
        let usage = UsageTracker.current(in: context)
        
        switch type {
        case .podcast:
            return usage.totalPodcasts < limits.maxPodcasts
        case .episode:
            return usage.dailyEpisodes < limits.maxDailyEpisodes
        case .extendedEpisode:
            return usage.dailyExtendedEpisodes < limits.maxDailyExtendedEpisodes
        }
    }
    
    func canCreateEpisode(length: EpisodeLength, in context: ModelContext) -> Bool {
        switch length {
        case .long:
            return canCreate(.extendedEpisode, in: context)
        case .short, .medium:
            return canCreate(.episode, in: context)
        }
    }
    
    func usageText(for type: ContentType, in context: ModelContext) -> String {
        guard !isLoading, isAuthenticated else { return "Loading..." }
        
        let usage = UsageTracker.current(in: context)
        
        switch type {
        case .podcast:
            return "\(usage.totalPodcasts)/\(limits.maxPodcasts)"
        case .episode:
            return "\(usage.dailyEpisodes)/\(limits.maxDailyEpisodes)"
        case .extendedEpisode:
            return "\(usage.dailyExtendedEpisodes)/\(limits.maxDailyExtendedEpisodes)"
        }
    }
    
    // MARK: - Private Methods
    private func checkAuthenticationStatus() {
#if DEBUG
        if let token = APIConfig.shared.apiToken {
            isAuthenticated = true
            Task { await refreshSubscriptionStatus() }
            return
        }
#endif
        
        if keychain.retrieve(key: Keys.token) != nil {
            isAuthenticated = true
            Task { await refreshSubscriptionStatus() }
        }
    }
    
    private func storeCredentials(token: String, email: String?) {
        _ = keychain.store(key: Keys.token, value: token)
        if let email {
            _ = keychain.store(key: Keys.email, value: email)
        }
        isAuthenticated = true
    }
    
    private func clearCredentials() {
        _ = keychain.delete(key: Keys.token)
        _ = keychain.delete(key: Keys.email)
        isAuthenticated = false
    }
    
    private func resetToDefaults() {
        subscriptionTier = .free
        limits = Limits.free
    }
    
    private func startSubscriptionListener() {
        subscriptionListener = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshSubscriptionStatus()
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
    
    private func fetchLimits() async {
        guard let token = currentToken else {
            limits = subscriptionTier == .premium ? .premium : .free
            return
        }
        
        do {
            let response = try await client.getSubscriptionLimits(
                tier: subscriptionTier.rawValue,
                authToken: token
            )
            
            limits = Limits(
                maxPodcasts: response.maxPodcasts,
                maxDailyEpisodes: response.maxDailyEpisodes,
                maxDailyExtendedEpisodes: response.maxDailyExtendedEpisodes
            )
        } catch {
            print("Failed to fetch limits: \(error)")
            // Fallback to default limits for the tier
            limits = subscriptionTier == .premium ? .premium : .free
        }
    }
    
}

// MARK: - Supporting Types
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
