import SwiftUI
import SwiftData

@MainActor
@Observable
final class UsageManager {
    private(set) var limits: Limits = .free
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
            print("Failed to fetch limits:", error)
            limits = tier == .premium ? .premium : .free
        }
    }

    func canCreate(_ type: ContentType, in context: ModelContext) -> Bool {
        switch type {
        case .podcast:
            currentUsage(in: context).totalPodcasts < limits.maxPodcasts
        case .episode:
            currentUsage(in: context).dailyEpisodes < limits.maxDailyEpisodes
        case .extendedEpisode:
            currentUsage(in: context).dailyExtendedEpisodes < limits.maxDailyExtendedEpisodes
        }
    }

    func canCreateEpisode(length: EpisodeLength, in context: ModelContext) -> Bool {
        length == .long
        ? canCreate(.extendedEpisode, in: context)
        : canCreate(.episode, in: context)
    }

    func usageText(for type: ContentType, in context: ModelContext) -> String {
        let u = currentUsage(in: context)
        switch type {
        case .podcast:
            return "\(u.totalPodcasts)/\(limits.maxPodcasts)"
        case .episode:
            return "\(u.dailyEpisodes)/\(limits.maxDailyEpisodes)"
        case .extendedEpisode:
            return "\(u.dailyExtendedEpisodes)/\(limits.maxDailyExtendedEpisodes)"
        }
    }

    private func currentUsage(in context: ModelContext) -> (
        totalPodcasts: Int,
        dailyEpisodes: Int,
        dailyExtendedEpisodes: Int
    ) {
        let interval = Calendar.current.dateInterval(of: .day, for: .now)!
        let failed = EpisodeStatus.failed.rawValue

        let totalPodcasts = (try? context.fetchCount(FetchDescriptor<Podcast>())) ?? 0

        let dailyEpisodes = countEpisodes(
            in: context,
            predicate: #Predicate<Episode> {
                $0.createdAt >= interval.start && $0.createdAt < interval.end &&
                $0.length != "long" && $0.status != failed
            }
        )

        let dailyExtendedEpisodes = countEpisodes(
            in: context,
            predicate: #Predicate<Episode> {
                $0.createdAt >= interval.start && $0.createdAt < interval.end &&
                $0.length == "long" && $0.status != failed
            }
        )

        return (totalPodcasts, dailyEpisodes, dailyExtendedEpisodes)
    }

    private func countEpisodes(
        in context: ModelContext,
        predicate: Predicate<Episode>
    ) -> Int {
        (try? context.fetchCount(FetchDescriptor<Episode>(predicate: predicate))) ?? 0
    }
}


enum ContentType {
    case podcast, episode, extendedEpisode
}


