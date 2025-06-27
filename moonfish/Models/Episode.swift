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
    var instruction: String
    
    var title: String
    var summary: String
    var fileName: String
    var duration: Double
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
        instruction: String = "",
        
        title: String,
        summary: String,
        fileName: String,
        duration: Double,
        createdAt: Date,
        
        isFavorite: Bool = false,
        isDownloaded: Bool = false,
        
        url: URL? = nil,
        expiresAt: Date? = nil,
        
        downloadState: DownloadState = .idle,
        
        podcast: Podcast,
    ) {
        self.serverId = serverId
        
        self.topic = topic
        self.length = length
        self.level = level
        self.instruction = instruction

        self.title = title
        self.summary = summary
        self.fileName = fileName
        self.duration = duration
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.isDownloaded = isDownloaded
        
        self.audioURL = url
        self.expiresAt = expiresAt
        
        self.downloadState = downloadState
        
        self.podcast = podcast
    }
    
    convenience init? (from podcastResponse: CompletedEpisodeResponse, for podcast: Podcast) {
        self.init(
            serverId: podcastResponse.id,
            topic: podcastResponse.topic,
            length: podcastResponse.length,
            level: podcastResponse.level,
            instruction: podcastResponse.instruction,
            title: podcastResponse.title,
            summary: podcastResponse.summary,
            fileName: podcastResponse.fileName,
            duration: podcastResponse.duration,
            createdAt: podcastResponse.createdAt,
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
}

extension Episode {
    enum DownloadState: String, CaseIterable, Codable {
        case idle = "idle"
        case downloading = "downloading"
    }
    
    var fileURL: URL {
        URL.documentsDirectory
            .appending(path: "\(self.serverId)")
            .appendingPathExtension("mp3")
    }
    
    var downloadProgress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(currentBytes) / Double(totalBytes)
    }

    func update(currentBytes: Int64, totalBytes: Int64) {
        self.currentBytes = currentBytes
        self.totalBytes = totalBytes
    }
}

extension Episode {
    @MainActor
    static var preview = Episode(
        serverId: 0,
        topic: "Sustainable Urban Gardening",
        length: "short",
        level: "beginner",
        title: "Beginner's Guide to Gardening in the Far East",
        summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
//        transcript: "Welcome to your first step into gardening! This podcast, made just for you, will cover the basics...",
        fileName: "gardening_beginner.mp3",
        duration: 620, // about 10 minutes
        createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600), // Created an hour after the request
        isDownloaded: true,
        downloadState: .downloading,
        
        podcast: Podcast.preview
    )
}


