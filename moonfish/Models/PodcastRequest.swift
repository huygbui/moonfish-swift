//
//  PodcastRequest.swift
//  moonfish
//
//  Created by Huy Bui on 14/5/25.
//

import Foundation
import SwiftData

@Model
final class PodcastRequest {
    var id: UUID
    var status: RequestStatus.RawValue
    var progressValue: Double
    var configuration: PodcastConfiguration
    var createdDate: Date
    var title: String?
    var step: RequestStep.RawValue?
    var completedPodcast: Podcast?
    
    init(
        id: UUID = UUID(),
        status: RequestStatus = .pending,
        progressValue: Double = 0,
        configuration: PodcastConfiguration,
        createdDate: Date = Date(),
        title: String? = "Untitled",
        step: RequestStep? = nil,
        completedPodcast: Podcast? = nil
    ) {
        self.id = id
        self.status = status.rawValue
        self.progressValue = progressValue
        self.configuration = configuration
        self.createdDate = createdDate
        self.title = title
        self.step = step?.rawValue
        self.completedPodcast = completedPodcast
    }

    var statusDescription: String? {
        guard let currentStatus = RequestStatus(rawValue: self.status) else { return nil }
        return currentStatus.description
    }
    
    var stepDescription: String? {
        guard let step = self.step, let currentStep = RequestStep(rawValue: step) else { return nil }
        return currentStep.description
    }
}

enum RequestStatus: Int, CaseIterable {
    case pending
    case active
    case completed
    case cancelled
    
    var description: String {
        switch self {
        case .pending:
            return "Pending"
        case .active:
            return "Active"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
}

enum RequestStep: Int, CaseIterable {
    case research
    case compose
    case voice
    
    var description: String {
        switch self {
        case .research:
            return "Researching"
        case .compose:
            return "Composing the script"
        case .voice:
            return "Voicing"
        }
    }
}
