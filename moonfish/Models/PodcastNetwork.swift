//
//  PodcastNetwork.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import Foundation

struct PodcastCreateRequest: Codable {
    var title: String
    var about: String
    var format: EpisodeFormat
    var name1: String
    var voice1: EpisodeVoice
    var name2: String?
    var voice2: EpisodeVoice?
}

struct PodcastCreateResponse: Codable, Identifiable {
    var id: Int
    
    var title: String
    var about: String?
    var format: String
    var name1: String
    var voice1: String
    var name2: String?
    var voice2: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, about, format, name1, voice1, name2, voice2
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
