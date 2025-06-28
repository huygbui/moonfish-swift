//
//  PodcastNetwork.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import Foundation

struct PodcastCreateRequest: Codable {
    var title: String
    var format: EpisodeFormat
    var name1: String
    var voice1: EpisodeVoice
    var name2: String?
    var voice2: EpisodeVoice?
    var description: String?
}

struct PodcastCreateResponse: Codable, Identifiable {
    var id: Int
    
    var title: String
    var format: String
    var name1: String
    var voice1: String
    var name2: String?
    var voice2: String?
    var description: String?

    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, format, name1, voice1, name2, voice2, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
