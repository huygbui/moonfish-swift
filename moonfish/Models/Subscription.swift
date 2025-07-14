//
//  Subscription.swift
//  moonfish
//
//  Created by Huy Bui on 14/7/25.
//

import Foundation

struct SubscriptionLimitsResponse: Codable {
    let tier: String
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

struct TierUpdateRequest: Codable {
    let tier: String
}


