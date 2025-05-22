//
//  PodcastConfiguration.swift
//  moonfish
//
//  Created by Huy Bui on 15/5/25.
//

import Foundation

struct PodcastConfiguration: Codable {
    var topic: String
    var length: PodcastLength
    var level: PodcastLevel
    var format: PodcastFormat
    var voice: PodcastVoice
    var instruction: String = ""
}

