//
//  PodcastConfiguration.swift
//  moonfish
//
//  Created by Huy Bui on 15/5/25.
//

import SwiftUI

struct EpisodeConfig: Codable {
    var topic: String
    var length: EpisodeLength
    var level: EpisodeLevel
    var format: EpisodeFormat
    var voice: EpisodeVoice
    var instruction: String
}

enum EpisodeLength: String, Identifiable, CaseIterable, Codable {
    case short, medium, long
    var id: Self { self }
}

enum EpisodeLevel: String, Identifiable, CaseIterable, Codable {
    case beginner, intermediate, advanced
    var id: Self { self }
}

enum EpisodeVoice: String, Identifiable, CaseIterable, Codable {
    case male, female
    var id: Self { self }
}

enum EpisodeFormat: String, Identifiable, CaseIterable, Codable {
    case narrative, conversational
    var id: Self { self }
}


