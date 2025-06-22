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
    var duration: Double
    var createdAt: Date
    var isFavorite: Bool
    
    var url: URL?
    var expiresAt: Date?
    
    var downloadState: DownloadState
    var resumeData: Data?
    private(set) var currentBytes: Int64 = 0
    private(set) var totalBytes: Int64 = 0
    
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
        duration: Double,
        createdAt: Date,
        isFavorite: Bool = false,
        isDownloaded: Bool = false,
        url: URL? = nil,
        expiresAt: Date? = nil,
        
        downloadState: DownloadState = .idle,
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
        
        self.url = url
        self.expiresAt = expiresAt
        
        self.downloadState = downloadState
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

extension Podcast {
    enum DownloadState: String, CaseIterable, Codable {
        case idle = "idle"
        case dowloading = "downloading"
        case completed = "completed"
        case canceled = "canceled"
    }
    
    var fileURL: URL {
        URL.documentsDirectory
            .appending(path: "\(id)")
            .appendingPathExtension(".mp3")
    }
    
    var downloadProgress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(currentBytes) / Double(totalBytes)
    }

//    var isDownloadCompleted: Bool {
//        currentBytes == totalBytes && totalBytes > 0
//    }

    func update(currentBytes: Int64, totalBytes: Int64) {
        self.currentBytes = currentBytes
        self.totalBytes = totalBytes
    }
}

extension Podcast {
    @MainActor
    static var preview = Podcast(
        taskId: 0,
        topic: "Sustainable Urban Gardening",
        length: "short",
        level: "beginner",
        format: "conversational",
        voice: "female",
        title: "Beginner's Guide to Gardening in the Far East",
        summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
//        transcript: "Welcome to your first step into gardening! This podcast, made just for you, will cover the basics...",
        fileName: "gardening_beginner.mp3",
        duration: 620, // about 10 minutes
        createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600) // Created an hour after the request
    )
}


