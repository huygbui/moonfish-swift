import SwiftUI
import SwiftData

@MainActor
@Observable
final class UsageManager {
    private(set) var limits: Limits = .free
    private(set) var usage: Usage = .zero
    private let client = NetworkClient()
    
    func refresh() async {
        do {
            let response = try await client.getUsage()
            limits = Limits(
                maxPodcasts: response.maxPodcasts,
                maxDailyEpisodes: response.maxDailyEpisodes,
                maxDailyExtendedEpisodes: response.maxDailyExtendedEpisodes
            )
            
            usage = Usage(
                podcasts: response.podcasts,
                dailyEpisodes: response.dailyEpisodes,
                dailyExtendedEpisodes: response.dailyExtendedEpisodes
            )
        } catch {
            print("Failed to refresh usage:", error)
            limits = .free
        }
    }

    func canCreate(_ type: ContentType, in context: ModelContext) -> Bool {
        switch type {
        case .podcast:
            usage.podcasts < limits.maxPodcasts
        case .episode:
            usage.dailyEpisodes < limits.maxDailyEpisodes
        case .extendedEpisode:
            usage.dailyExtendedEpisodes < limits.maxDailyExtendedEpisodes
        }
    }

    func canCreateEpisode(length: EpisodeLength, in context: ModelContext) -> Bool {
        length == .long
        ? canCreate(.extendedEpisode, in: context)
        : canCreate(.episode, in: context)
    }

    func usageText(for type: ContentType) -> String {
        switch type {
        case .podcast:
            return "\(usage.podcasts)/\(limits.maxPodcasts)"
        case .episode:
            return "\(usage.dailyEpisodes)/\(limits.maxDailyEpisodes)"
        case .extendedEpisode:
            return "\(usage.dailyExtendedEpisodes)/\(limits.maxDailyExtendedEpisodes)"
        }
    }
}


enum ContentType {
    case podcast, episode, extendedEpisode
}


