//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 10/5/25.
//

import SwiftUI
import SwiftData

@Model
final class Podcast {
    var title: String
    var summary: String
    var transcript: String
    var audioURL: URL
    var duration: Int
    var createdAt: Date
    var configuration: PodcastConfiguration
    
    var wasPlayed: Bool
    
    init(
        title: String,
        summary: String,
        transcript: String,
        audioURL: URL,
        duration: Int,
        createdAt: Date,
        configuration: PodcastConfiguration,
        
        wasPlayed: Bool = false
    ) {
        self.title = title
        self.summary = summary
        self.transcript = transcript
        self.audioURL = audioURL
        self.duration = duration
        self.createdAt = createdAt
        self.configuration = configuration
        self.wasPlayed = wasPlayed
    }
}



enum PodcastLength: String, Identifiable, CaseIterable, Codable {
    case short
    case medium
    case long
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .short:
            return "Bite-sized"
        case .medium:
            return "Standard"
        case .long:
            return "Extended"
        }
    }
}

enum PodcastVoice: String, Identifiable, CaseIterable, Codable {
    case male
    case female
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        }
    }
}

enum PodcastFormat: String, Identifiable, CaseIterable, Codable {
    case narrative
    case conversational
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .narrative:
            return "Narrative"
        case .conversational:
            return "Conversational"
        }
    }
}

enum PodcastLevel: String, Identifiable, CaseIterable, Codable {
    case beginner
    case intermediate
    case advanced
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        }
    }
}

