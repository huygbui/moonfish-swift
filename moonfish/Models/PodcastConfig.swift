//
//  PodcastConfiguration.swift
//  moonfish
//
//  Created by Huy Bui on 15/5/25.
//

import SwiftUI

struct PodcastConfig: Codable {
    var topic: String
    var length: PodcastLength
    var level: PodcastLevel
    var format: PodcastFormat
    var voice: PodcastVoice
    var instruction: String
}

enum PodcastLength: String, Identifiable, CaseIterable, Codable {
    case short, medium, long
    var id: Self { self }
}

enum PodcastLevel: String, Identifiable, CaseIterable, Codable {
    case beginner, intermediate, advanced
    var id: Self { self }
}

enum PodcastVoice: String, Identifiable, CaseIterable, Codable {
    case male, female
    var id: Self { self }
}

enum PodcastFormat: String, Identifiable, CaseIterable, Codable {
    case narrative, conversational
    var id: Self { self }
}


