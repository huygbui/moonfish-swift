//
//  UsageManager.swift
//  moonfish
//
//  Created by Huy Bui on 15/7/25.
//

import SwiftUI
import SwiftData

@MainActor
@Observable
final class UsageLimitsManager {
    private(set) var limits = Limits.loading
    private let client = NetworkClient()
    
    func refreshLimits(tier: Tier, token: String?) async {
        guard let token else {
            limits = tier == .premium ? .premium : .free
            return
        }
        
        do {
            let response = try await client.getSubscriptionTier(
                tier: tier.rawValue,
                authToken: token
            )
            
            limits = Limits(
                maxPodcasts: response.maxPodcasts,
                maxDailyEpisodes: response.maxDailyEpisodes,
                maxDailyExtendedEpisodes: response.maxDailyExtendedEpisodes
            )
        } catch {
            print("Failed to fetch limits: \(error)")
            limits = tier == .premium ? .premium : .free
        }
    }
    
    func canCreate(_ type: ContentType, in context: ModelContext) -> Bool {
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
}


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
