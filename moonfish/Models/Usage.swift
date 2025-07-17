//
//  Limit.swift
//  moonfish
//
//  Created by Huy Bui on 15/7/25.
//

import Foundation


struct Counter: Equatable {
    var current: Int
    let limit: Int
    
    var isAvailable: Bool { current < limit }
    var description: String { "\(current)/\(limit)" }
}

struct Usage {
    var podcasts: Counter
    var dailyEpisodes: Counter
    var dailyExtendedEpisodes: Counter
    
    static let `default` = Usage(
        podcasts: Counter(current: 0, limit: 1),
        dailyEpisodes: Counter(current: 0, limit: 1),
        dailyExtendedEpisodes: Counter(current: 0, limit: 0)
    )
}

