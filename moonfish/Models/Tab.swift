//
//  Tab.swift
//  moonfish
//
//  Created by Huy Bui on 10/5/25.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case completed = "Completed"
    case inProgress = "In Progress"
    
    var filter: Predicate<PodcastTask> {
        let completedStatusValue = TaskStatus.completed.rawValue
        let cancelledStatusValue = TaskStatus.cancelled.rawValue
        
        switch self {
        case .completed:
            return #Predicate<PodcastTask> {
                $0.status == completedStatusValue
            }
        case .inProgress:
            return #Predicate<PodcastTask> {
                $0.status != completedStatusValue && $0.status != cancelledStatusValue
            }
        }
    }
}


