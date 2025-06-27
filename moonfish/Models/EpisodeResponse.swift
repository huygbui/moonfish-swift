//
//  PodcastResponse.swift
//  moonfish
//
//  Created by Huy Bui on 18/6/25.
//

import Foundation

struct CompletedEpisodeResponse: Codable, Identifiable {
    var id: Int
    
    var topic: String
    var length: String
    var level: String
    var format: String
    var voice: String
    var instruction: String = ""
    
    var status: String
    var title: String
    var summary: String
    var fileName: String
    var duration: Double
    
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, topic, length, level, format, voice, instruction, status, title, summary, duration
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fileName = "file_name"
    }
}

struct OngoingEpisodeResponse: Codable, Identifiable {
    var id: Int
    
    var topic: String
    var length: String
    var level: String
    var format: String
    var voice: String
    var instruction: String?
    
    var status: String
    var step: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, topic, length, level, format, voice, instruction, status, step
        case createdAt = "created_at"
        case updatedAt = "updated_at"
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
