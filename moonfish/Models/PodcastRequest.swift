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
    var id: Int
    var status: RequestStatus.RawValue
    var progressValue: Double
    var configuration: PodcastConfiguration
    var createdAt: Date
    var updatedAt: Date
    var step: RequestStep.RawValue?
    var completedPodcast: Podcast?
    
    init(
        id: Int,
        status: RequestStatus = .pending,
        progressValue: Double = 0,
        configuration: PodcastConfiguration,
        createdAt: Date,
        updatedAt: Date,
        step: RequestStep? = nil,
        completedPodcast: Podcast? = nil
    ) {
        self.id = id
        self.status = status.rawValue
        self.progressValue = progressValue
        self.configuration = configuration
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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

enum RequestStatus: String, CaseIterable {
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

enum RequestStep: String, CaseIterable {
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
