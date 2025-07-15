//
//  Limit.swift
//  moonfish
//
//  Created by Huy Bui on 15/7/25.
//

import Foundation

struct Limits {
    let maxPodcasts: Int
    let maxDailyEpisodes: Int
    let maxDailyExtendedEpisodes: Int
    
    static let free = Limits(
        maxPodcasts: 1,
        maxDailyEpisodes: 1,
        maxDailyExtendedEpisodes: 1
    )
    
    static let premium = Limits(
        maxPodcasts: 12,
        maxDailyEpisodes: 12,
        maxDailyExtendedEpisodes: 3
    )
}
