//
//  Episode+FetchDescriptor.swift
//  moonfish
//
//  Created by Huy Bui on 2/7/25.
//

import Foundation
import SwiftData


extension Episode {
    static func buildPredicate(status: EpisodeStatus, dateFilter: EpisodeDateFilter) -> Predicate<Episode> {
        let calendar = Calendar.autoupdatingCurrent
        let statusString = status.rawValue
        switch dateFilter {
        case .within(let days):
            let cutoff = calendar.date(byAdding: .day, value: -days, to: Date.now) ?? Date.now
            return #Predicate<Episode> { $0.createdAt >= cutoff && $0.status == statusString }
        case .older(let days):
            let cutoff = calendar.date(byAdding: .day, value: -days, to: Date.now) ?? Date.now
            return #Predicate<Episode> { $0.createdAt < cutoff && $0.status == statusString }
        case .all:
            return #Predicate<Episode> { $0.status == statusString }
        }
    }
    
    static func buildFetchDescriptor(
        status: EpisodeStatus = .completed,
        dateFilter: EpisodeDateFilter = .all,
        limit: Int? = nil
    ) -> FetchDescriptor<Episode> {
        let predicate = self.buildPredicate(status: status, dateFilter: dateFilter)
        
        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return descriptor
    }
    
    static var recentDescriptor: FetchDescriptor<Episode> {
        return self.buildFetchDescriptor(status: .completed, dateFilter: .within(days: 3), limit: 8)
    }
    
    static var pastDescriptor: FetchDescriptor<Episode> {
        return self.buildFetchDescriptor(status: .completed, dateFilter: .older(thanDays: 3), limit: 4)
    }
}

enum EpisodeDateFilter {
    case within(days: Int)
    case older(thanDays: Int)
    case all
}
