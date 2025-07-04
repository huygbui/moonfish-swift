//
//  Podcast.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//
import SwiftUI
import SwiftData

@Model
final class Podcast {
    @Attribute(.unique) var serverId: Int
    
    var title: String
    var about: String?
    var format: EpisodeFormat
    var name1: String?
    var voice1: EpisodeVoice
    var name2: String?
    var voice2: EpisodeVoice?
    
    var imageURL: URL?
   
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Episode.podcast)
    var episodes = [Episode]()
   
    init(
        serverId: Int,
        title: String,
        about: String? = nil,
        format: EpisodeFormat,
        name1: String,
        voice1: EpisodeVoice,
        name2: String? = nil,
        voice2: EpisodeVoice? = nil,
        imageURL: URL? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.serverId = serverId
        self.title = title
        self.about = about
        self.format = format
        self.name1 = name1
        self.voice1 = voice1
        self.name2 = name2
        self.voice2 = voice2
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init(from createResponse: PodcastCreateResponse) {
        self.init(
            serverId: createResponse.id,
            title: createResponse.title,
            about: createResponse.description,
            format: createResponse.format,
            name1: createResponse.name1,
            voice1: createResponse.voice1,
            name2: createResponse.name2,
            voice2: createResponse.voice2,
            imageURL: createResponse.imageURL,
            createdAt: createResponse.createdAt,
            updatedAt: createResponse.updatedAt,
        )
    }
}

extension Podcast {
    @MainActor
    static var preview = Podcast(
        serverId: 0,
        title: "Weekly Tech News",
        format: .conversational,
        name1: "sam",
        voice1: .male,
        name2: "sally",
        voice2: .female,
        createdAt: Date(),
        updatedAt: Date()
    )
}

