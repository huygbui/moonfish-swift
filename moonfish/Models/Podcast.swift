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
    var format: String
    var name1: String
    var voice1: String
    var name2: String?
    var voice2: String?
    
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Episode.podcast)
    var episodes = [Episode]()
    
    @Attribute(.ephemeral) var imageURL: URL?
   
    init(
        serverId: Int,
        title: String,
        about: String? = nil,
        format: String,
        name1: String,
        voice1: String,
        name2: String? = nil,
        voice2: String? = nil,
        createdAt: Date,
        updatedAt: Date,
        imageURL: URL? = nil
    ) {
        self.serverId = serverId
        self.title = title
        self.about = about
        self.format = format
        self.name1 = name1
        self.voice1 = voice1
        self.name2 = name2
        self.voice2 = voice2
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.imageURL = imageURL
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
            createdAt: createResponse.createdAt,
            updatedAt: createResponse.updatedAt,
            imageURL: createResponse.imageURL
        )
    }
}

extension Podcast {
    @MainActor
    static var preview = Podcast(
        serverId: 0,
        title: "Weekly Tech News",
        format: "conversational",
        name1: "sam",
        voice1: "male",
        name2: "sally",
        voice2: "female",
        createdAt: Date(),
        updatedAt: Date()
    )
}

