//
//  SubscriptionManager.swift
//  moonfish
//
//  Created by Huy Bui on 14/7/25.
//

import SwiftUI
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
    
    // MARK: - Public Interface
    func canCreatePodcast(currentCount: Int) -> Bool {
        currentCount < maxPodcasts
    }
    
    func canCreateEpisode(episodesToday: Int) -> Bool {
        episodesToday < maxDailyEpisodes
    }
    
    func canCreateExtendedEpisode(extendedEpisodesToday: Int) -> Bool {
        extendedEpisodesToday < maxDailyExtendedEpisodes
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
        
        do {
            let response = try await client.getSubscriptionLimits(tier: subscriptionTier.rawValue, authToken: token)
            maxPodcasts = response.maxPodcasts
            maxDailyEpisodes = response.maxDailyEpisodes
            maxDailyExtendedEpisodes = response.maxDailyExtendedEpisodes
            
            if let serverTier = SubscriptionTier(rawValue: response.tier) {
                subscriptionTier = serverTier
            }
        } catch {
            print("Failed to fetch limits: \(error)")
            applyDefaultLimits()
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
