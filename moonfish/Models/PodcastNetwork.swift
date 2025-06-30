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
    var format: EpisodeFormat
    var name1: String
    var voice1: EpisodeVoice
    var name2: String?
    var voice2: EpisodeVoice?
    var description: String?

    var createdAt: Date
    var updatedAt: Date
    
    var imageURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, title, format, name1, voice1, name2, voice2, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case imageURL = "image_url"
    }
}

struct PodcastImageUploadURLRequest: Codable {
    var podcastId: Int
    
    enum CodingKeys: String, CodingKey {
        case podcastId = "podcast_id"
    }
}

struct PodcastImageUploadURLResponse: Codable {
    var url: URL
}

struct PodcastUpdateRequest: Codable {
    let title: String?
    let format: EpisodeFormat?
    let name1: String?
    let voice1: EpisodeVoice?
    let name2: String?
    let voice2: EpisodeVoice?
    let description: String?
    
    // Only include non-nil fields in JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(format, forKey: .format)
        try container.encodeIfPresent(name1, forKey: .name1)
        try container.encodeIfPresent(voice1, forKey: .voice1)
        try container.encodeIfPresent(name2, forKey: .name2)
        try container.encodeIfPresent(voice2, forKey: .voice2)
        try container.encodeIfPresent(description, forKey: .description)
    }
}
