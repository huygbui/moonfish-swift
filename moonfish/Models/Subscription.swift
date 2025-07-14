//
//  Subscription.swift
//  moonfish
//
//  Created by Huy Bui on 14/7/25.
//

import Foundation

struct SubscriptionTierResponse: Codable {
    let tier: Tier
    let maxPodcasts: Int
    let maxDailyEpisodes: Int
    let maxDailyExtendedEpisodes: Int

    enum CodingKeys: String, CodingKey {
        case tier
        case maxPodcasts = "max_podcasts"
        case maxDailyEpisodes = "max_daily_episodes"
        case maxDailyExtendedEpisodes = "max_daily_extended_episodes"
    }
}

enum Tier: String, Codable, CaseIterable {
    case free = "free"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .free: return "Free Plan"
        case .premium: return "Premium Plan"
        }
    }
}

struct TierUpdateRequest: Codable {
    let tier: String
}


