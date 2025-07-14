//
//  SubscriptionManager.swift
//  moonfish
//
//  Created by Huy Bui on 14/7/25.
//

import SwiftUI
import SwiftData
import StoreKit

@MainActor
@Observable
final class SubscriptionManager {
    
    enum SubscriptionTier: String, CaseIterable {
        case free = "free"
        case premium = "premium"
    }
    
    private(set) var subscriptionTier: SubscriptionTier = .free
    private(set) var maxPodcasts: Int = 1
    private(set) var maxDailyEpisodes: Int = 1
    private(set) var maxDailyExtendedEpisodes: Int = 0
    private(set) var isInitialized: Bool = false
    
    private let client = BackendClient()
    private var authManager: AuthManager?
    private var updateListenerTask: Task<Void, Never>?
    
    init() {
        startListening()
    }
    
    // MARK: - Auth Lifecycle
    func setAuthManager(_ authManager: AuthManager) async {
        self.authManager = authManager
        isInitialized = true
        
        await fetchLimits()
    }
    
    func clearAuth() async {
        authManager = nil
        isInitialized = false
        
        subscriptionTier = .free
        applyDefaultLimits()
    }
    
    // MARK: - Limit Checking with Current Usage
    func canCreatePodcast(in context: ModelContext) -> Bool {
        guard isInitialized else { return false }
        let current = UsageTracker.totalPodcasts(in: context)
        return current < maxPodcasts
    }
    
    func canCreateEpisode(in context: ModelContext) -> Bool {
        guard isInitialized else { return false }
        let current = UsageTracker.dailyEpisodes(in: context)
        return current < maxDailyEpisodes
    }
    
    func canCreateExtendedEpisode(in context: ModelContext) -> Bool {
        guard isInitialized else { return false }
        let current = UsageTracker.dailyExtendedEpisodes(in: context)
        return current < maxDailyExtendedEpisodes
    }
    
    func canCreateEpisode(length: EpisodeLength, in context: ModelContext) -> Bool {
        switch length {
        case .long:
            return canCreateExtendedEpisode(in: context)
        case .short, .medium:
            return canCreateEpisode(in: context)
        }
    }
    
    func podcastUsageText(in context: ModelContext) -> String {
        guard isInitialized else { return "Loading..." }
        let current = UsageTracker.totalPodcasts(in: context)
        return "\(current)/\(maxPodcasts)"
    }
    
    func episodeUsageText(in context: ModelContext) -> String {
        guard isInitialized else { return "Loading..." }
        let current = UsageTracker.dailyEpisodes(in: context)
        return "\(current)/\(maxDailyEpisodes)"
    }
    
    func extendedEpisodeUsageText(in context: ModelContext) -> String {
        guard isInitialized else { return "Loading..." }
        let current = UsageTracker.dailyExtendedEpisodes(in: context)
        return "\(current)/\(maxDailyExtendedEpisodes)"
    }
    
    var isSubscribed: Bool {
        subscriptionTier == .premium
    }
    
    var subscriptionDisplayName: String {
        switch subscriptionTier {
        case .free: return "Free Plan"
        case .premium: return "Premium Plan"
        }
    }
    
    // MARK: - Private Methods
    private func startListening() {
        updateListenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                
                do {
                    let transaction = try checkVerified(result)
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func checkForActiveSubscription() async -> Bool {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if (transaction.productID.contains("monthly") || transaction.productID.contains("annual"))
                    && !transaction.isUpgraded {
                    return true
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        return false
    }
    
    private func fetchLimits() async {
        guard let token = authManager?.token else {
            applyDefaultLimits()
            return
        }
        
        // 1. Check StoreKit for actual subscription status (source of truth)
        let hasActiveSubscription = await checkForActiveSubscription()
        subscriptionTier = hasActiveSubscription ? .premium : .free
        
        // 2. Fetch limits from backend based on determined tier
        do {
            let response = try await client.getSubscriptionLimits(
                tier: subscriptionTier.rawValue,
                authToken: token
            )
            
            maxPodcasts = response.maxPodcasts
            maxDailyEpisodes = response.maxDailyEpisodes
            maxDailyExtendedEpisodes = response.maxDailyExtendedEpisodes
            
        } catch {
            print("Failed to fetch limits: \(error)")
            applyDefaultLimits() // Fallback to hardcoded limits
        }
    }
    
    private func applyDefaultLimits() {
        switch subscriptionTier {
        case .free:
            maxPodcasts = 3
            maxDailyEpisodes = 3
            maxDailyExtendedEpisodes = 1
        case .premium:
            maxPodcasts = 12
            maxDailyEpisodes = 12
            maxDailyExtendedEpisodes = 3
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    enum StoreError: Error {
        case failedVerification
    }
}
