//
//  UsageTracker.swift
//  moonfish
//
//  Created by Huy Bui on 14/7/25.
//

import Foundation
import SwiftData


struct UsageTracker {
    static func totalPodcasts(in context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Podcast>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    static func dailyEpisodes(in context: ModelContext) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        let completedStatusString = EpisodeStatus.completed.rawValue
        let cancelledStatusString = EpisodeStatus.cancelled.rawValue
        let predicate = #Predicate<Episode> { episode in
            episode.createdAt >= today &&
            episode.createdAt < tomorrow &&
            episode.length != "long" &&
            (episode.status == completedStatusString || episode.status == cancelledStatusString)
        }
        
        let descriptor = FetchDescriptor<Episode>(predicate: predicate)
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    static func dailyExtendedEpisodes(in context: ModelContext) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        let completedStatusString = EpisodeStatus.completed.rawValue
        let cancelledStatusString = EpisodeStatus.cancelled.rawValue
        let predicate = #Predicate<Episode> { episode in
            episode.createdAt >= today &&
            episode.createdAt < tomorrow &&
            episode.length == "long" &&
            (episode.status == completedStatusString || episode.status == cancelledStatusString)
        }
        
        let descriptor = FetchDescriptor<Episode>(predicate: predicate)
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}
