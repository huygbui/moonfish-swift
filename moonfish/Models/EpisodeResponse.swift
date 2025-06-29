//
//  PodcastResponse.swift
//  moonfish
//
//  Created by Huy Bui on 18/6/25.
//

import Foundation


struct EpisodeResponse: Codable, Identifiable {
    var id: Int
    var podcastId: Int
    
    var topic: String
    var length: String
    var level: String
    var format: String
    var voice1: String
    var name1: String?
    var voice2: String?
    var name2: String?
    var instruction: String = ""
    
    var status: String
    var step: String?
    
    var title: String?
    var summary: String?
    var fileName: String?
    var duration: Double?
    
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, topic, length, level, format, voice1, name1, voice2, name2, instruction, status, step, title, summary, duration
        case podcastId = "podcast_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fileName = "file_name"
    }
}

struct EpisodeContentResponse: Codable {
    var id: Int
    var title: String
    var summary: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, summary
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct EpisodeAudioResponse: Codable {
    var url: URL
    var expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case url
        case expiresAt = "expires_at"
    }
}
