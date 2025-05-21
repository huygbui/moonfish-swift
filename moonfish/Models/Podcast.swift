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
    var title: String
    var summary: String
    var transcript: String
    var audioURL: URL
    var duration: Int
    var createdDate: Date
    var configuration: PodcastConfiguration
    
    init(
        title: String,
        summary: String,
        transcript: String,
        audioURL: URL,
        duration: Int,
        createdDate: Date,
        configuration: PodcastConfiguration
    ) {
        self.title = title
        self.summary = summary
        self.transcript = transcript
        self.audioURL = audioURL
        self.duration = duration
        self.createdDate = createdDate
        self.configuration = configuration
    }
}



enum PodcastLength: String, Identifiable, CaseIterable, Codable {
    case short = "Bite-sized"
    case medium = "Standard"
    case long = "Extended"
    var id: Self { self }
}

enum PodcastVoice: String, Identifiable, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    var id: Self { self }
}

enum PodcastFormat: String, Identifiable, CaseIterable, Codable {
    case narrative = "Narrative"
    case conversational = "Conversational"
    var id: Self { self }
}

enum PodcastLevel: String, Identifiable, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case expert = "Expert"
    var id: Self { self }
}

