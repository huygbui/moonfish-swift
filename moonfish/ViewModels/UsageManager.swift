import SwiftUI
import SwiftData

@MainActor
@Observable
final class UsageManager {
    private(set) var usage: Usage = .default
    
    private let client = NetworkClient()
    
    func refresh() async {
        do {
            let response = try await client.getUsage()
            usage = Usage(
                podcasts: Counter(current: response.podcasts, limit: response.maxPodcasts),
                dailyEpisodes: Counter(current: response.dailyEpisodes, limit: response.maxDailyEpisodes),
                dailyExtendedEpisodes: Counter(current: response.dailyExtendedEpisodes, limit: response.maxDailyExtendedEpisodes)
            )
        } catch {
            print("Failed to refresh usage:", error)
            usage = .default
        }
    }

    func canCreate(_ type: ContentType, in context: ModelContext) -> Bool {
        switch type {
        case .podcast: usage.podcasts.isAvailable
        case .episode: usage.dailyEpisodes.isAvailable
        case .extendedEpisode: usage.dailyExtendedEpisodes.isAvailable
        }
    }

    func canCreateEpisode(length: EpisodeLength, in context: ModelContext) -> Bool {
        length == .long
        ? canCreate(.extendedEpisode, in: context)
        : canCreate(.episode, in: context)
    }

    func usage(for type: ContentType) -> String {
        switch type {
        case .podcast: return usage.podcasts.description
        case .episode: return usage.dailyEpisodes.description
        case .extendedEpisode: return usage.dailyExtendedEpisodes.description
        }
    }
}


enum ContentType {
    case podcast, episode, extendedEpisode
}


