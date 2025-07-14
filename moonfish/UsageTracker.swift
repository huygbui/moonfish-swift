//
//  UsageTracker.swift
//  moonfish
//
//  Created by Huy Bui on 14/7/25.
//

import Foundation
import SwiftData


struct UsageTracker {
    struct Usage {
        let totalPodcasts: Int
        let dailyEpisodes: Int
        let dailyExtendedEpisodes: Int
    }
    
    static func current(in context: ModelContext) -> Usage {
        Usage(
            totalPodcasts: totalPodcasts(in: context),
            dailyEpisodes: dailyEpisodes(in: context),
            dailyExtendedEpisodes: dailyExtendedEpisodes(in: context)
        )
    }
    
    static func totalPodcasts(in context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Podcast>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    static func dailyEpisodes(in context: ModelContext) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        let failedStatusString = EpisodeStatus.failed.rawValue
        let predicate = #Predicate<Episode> { episode in
            episode.createdAt >= today &&
            episode.createdAt < tomorrow &&
            episode.length != "long" &&
            episode.status != failedStatusString
        }
        
        let descriptor = FetchDescriptor<Episode>(predicate: predicate)
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    static func dailyExtendedEpisodes(in context: ModelContext) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        let failedStatusString = EpisodeStatus.failed.rawValue
        let predicate = #Predicate<Episode> { episode in
            episode.createdAt >= today &&
            episode.createdAt < tomorrow &&
            episode.length == "long" &&
            episode.status != failedStatusString
        }
        
        let descriptor = FetchDescriptor<Episode>(predicate: predicate)
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}
