//
//  PodcastRequest.swift
//  moonfish
//
//  Created by Huy Bui on 14/5/25.
//

import Foundation

struct PodcastRequest: Codable, Identifiable {
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
    
    init(
        id: Int,
        topic: String,
        length: String,
        level: String,
        format: String,
        voice: String,
        instruction: String? = nil,
        status: String,
        step: String? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.topic = topic
        self.length = length
        self.level = level
        self.format = format
        self.voice = voice
        self.instruction = instruction
        self.status = status
        self.step = step
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension PodcastRequest {
    init(from response: OngoingPodcastResponse) {
        self.id = response.id
        self.topic = response.topic
        self.length = response.length
        self.level = response.level
        self.format = response.format
        self.voice = response.voice
        self.instruction = response.instruction
        self.status = response.status
        self.step = response.step
        self.createdAt = response.createdAt
        self.updatedAt = response.updatedAt
    }
}
 
extension PodcastRequest {
    var formattedStatus: String {
        switch status {
        case "pending":
            return "Pending"
        case "active":
            return "Active"
        case "completed":
            return "Completed"
        case "cancelled":
            return "Cancelled"
        default:
            return "Unknown"
        }
    }
    
    var formattedStep: String {
        switch step {
        case "research":
            return "Researching..."
        case "compose":
            return "Composing..."
        case "voice":
            return "Voicing..."
        default:
            return ""
        }
    }
    
    var progress: Double {
        switch step {
        case "research":
            return 0.125
        case "compose":
            return 0.25
        case "voice":
            return 0.50
        default:
            return 0
        }
    }
}


extension PodcastRequest {
    static let preview = PodcastRequest(
        id: 0,
        
        topic: "Sustainable Urban Gardening",
        length: "short",
        level: "beginner",
        format: "conversational",
        voice: "female",
        status: "active",
        step: "compose",
        
        createdAt: Date(),
        updatedAt: Date(),
    )
}

