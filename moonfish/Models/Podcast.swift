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
    @Attribute(.unique) var taskId: Int
    
    var topic: String
    var length: String
    var level: String
    var format: String
    var voice: String
    var instruction: String
    
    var title: String
    var summary: String
    var fileName: String
    var duration: Int
    var createdAt: Date
    var isFavorite: Bool
    var isDownloaded: Bool
    
    var url: URL?
    var expiresAt: Date?
    
    init(
        taskId: Int,
        
        topic: String,
        length: String,
        level: String,
        format: String,
        voice: String,
        instruction: String = "",
        
        title: String,
        summary: String,
        fileName: String,
        duration: Int,
        createdAt: Date,
        isFavorite: Bool = false,
        isDownloaded: Bool = false,
        url: URL? = nil,
        expiresAt: Date? = nil,
    ) {
        self.taskId = taskId
        
        self.topic = topic
        self.length = length
        self.level = level
        self.format = format
        self.voice = voice
        self.instruction = instruction

        self.title = title
        self.summary = summary
        self.fileName = fileName
        self.duration = duration
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.isDownloaded = isDownloaded
        
        self.url = url
        self.expiresAt = expiresAt
    }
    
    convenience init? (from podcastResponse: CompletedPodcastResponse) {
        self.init(
            taskId: podcastResponse.id,
            topic: podcastResponse.topic,
            length: podcastResponse.length,
            level: podcastResponse.level,
            format: podcastResponse.format,
            voice: podcastResponse.voice,
            instruction: podcastResponse.instruction,
            title: podcastResponse.title,
            summary: podcastResponse.summary,
            fileName: podcastResponse.fileName,
            duration: podcastResponse.duration,
            createdAt: podcastResponse.createdAt
        )
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

