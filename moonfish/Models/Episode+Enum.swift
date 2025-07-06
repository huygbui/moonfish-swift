//
//  Episode+Enum.swift
//  moonfish
//
//  Created by Huy Bui on 3/7/25.
//

import Foundation

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

enum EpisodeStatus: String, Identifiable, CaseIterable, Codable {
    case pending, active, completed, failed, cancelled
    var id: Self { self }
}

enum EpisodeStep: String, Identifiable, CaseIterable, Codable {
    case research, compose, voice
    var id: Self { self }
}
