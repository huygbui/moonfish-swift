//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 10/5/25.
//

import SwiftUI
import SwiftData

@Model
final class Episode {
    @Attribute(.unique) var serverId: Int
    
    var topic: String
    var length: String
    var level: String
    var instruction: String?
    
    var format: String
    var voice1: String
    var name1: String?
    var voice2: String?
    var name2: String?
    
    var status: String?
    var step: String?
    
    var title: String?
    var summary: String?
    var fileName: String?
    var duration: Double?
    var createdAt: Date
    
    var isFavorite: Bool
    var isDownloaded: Bool
    
    var audioURL: URL?
    var expiresAt: Date?
    
    @Attribute(.ephemeral) var downloadState: DownloadState
    @Attribute(.ephemeral) private(set) var currentBytes: Int64 = 0
    @Attribute(.ephemeral) private(set) var totalBytes: Int64 = 0
    
    var podcast: Podcast
    
    init(
        serverId: Int,
        
        topic: String,
        length: String,
        level: String,
        instruction: String? = nil,
        
        format: String,
        voice1: String,
        name1: String? = nil,
        voice2: String? = nil,
        name2: String? = nil,
        
        status: String? = nil,
        step: String? = nil,
        
        title: String? = nil,
        summary: String? = nil,
        fileName: String? = nil,
        duration: Double? = nil,
        createdAt: Date,
        
        isFavorite: Bool = false,
        isDownloaded: Bool = false,
        
        audioURL: URL? = nil,
        expiresAt: Date? = nil,
        
        downloadState: DownloadState = .idle,
        
        podcast: Podcast,
    ) {
        self.serverId = serverId
        
        self.topic = topic
        self.length = length
        self.level = level
        self.instruction = instruction
        
        self.format = format
        self.name1 = name1
        self.voice1 = voice1
        self.name2 = name1
        self.voice2 = voice1
        
        self.status = status
        self.step = step
        
        self.title = title
        self.summary = summary
        self.fileName = fileName
        self.duration = duration
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.isDownloaded = isDownloaded
        
        self.audioURL = audioURL
        self.expiresAt = expiresAt
        
        self.downloadState = downloadState
        
        self.podcast = podcast
    }
    
    convenience init(from response: EpisodeResponse, for podcast: Podcast) {
        self.init(
            serverId: response.id,
            
            topic: response.topic,
            length: response.length,
            level: response.level,
            instruction: response.instruction,
            
            format: response.format,
            voice1: response.voice1,
            name1: response.name1,
            voice2: response.voice2,
            name2: response.name2,
            
            status: response.status.rawValue,
            step: response.step?.rawValue,
            
            title: response.title,
            summary: response.summary,
            fileName: response.fileName,
            duration: response.duration,
            createdAt: response.createdAt,
            
            podcast: podcast
        )
    }
}

extension Episode {
    var isNew: Bool {
        createdAt.timeIntervalSinceNow > -1 * 24 * 60 * 60
    }
    
    var isRecent: Bool {
        createdAt.timeIntervalSinceNow > -3 * 24 * 60 * 60
    }
    
    var isCompleted: Bool {
        title != nil && summary != nil && audioURL != nil
    }
}

extension Episode {
    enum DownloadState: String, CaseIterable, Codable {
        case idle = "idle"
        case downloading = "downloading"
    }
    
    var downloadProgress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(currentBytes) / Double(totalBytes)
    }
    
    func update(currentBytes: Int64, totalBytes: Int64) {
        self.currentBytes = currentBytes
        self.totalBytes = totalBytes
    }
    
    var fileURL: URL {
        URL.documentsDirectory
            .appending(path: "\(self.serverId)")
            .appendingPathExtension("mp3")
    }
    
    var playbackURL: URL? {
        isDownloaded && FileManager.default.fileExists(atPath: fileURL.path)
        ? fileURL
        : audioURL
    }
    
    var currentProgress: Double {
        switch step {
        case EpisodeStep.research.rawValue: return 0.125
        case EpisodeStep.compose.rawValue: return 0.25
        case EpisodeStep.voice.rawValue: return 0.5
        default: return 0.0
        }
    }
}



extension Episode {
    @MainActor
    static var preview = Episode(
        serverId: 0,
        topic: "Sustainable Urban Gardening",
        length: "short",
        level: "beginner",
        
        format: "conversational",
        voice1: "male",
        name1: "John",
        voice2: "female",
        name2: "Jane",
        
        status: EpisodeStatus.active.rawValue,
        step: EpisodeStep.voice.rawValue,
        
        title: "Beginner's Guide to Gardening in the Far East",
        summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
        fileName: "gardening_beginner.mp3",
        duration: 620, // about 10 minutes
        createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600),
        isDownloaded: true,
        downloadState: .downloading,
        
        podcast: Podcast.preview
    )
}
