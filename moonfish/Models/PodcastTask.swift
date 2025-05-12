//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 10/5/25.
//

import SwiftUI
import SwiftData

struct PodcastConfiguration: Codable {
    var length: PodcastLength
    var level: PodcastLevel
    var format: PodcastFormat
    var voice: PodcastVoice

    static let `default` = PodcastConfiguration(
        length: .medium,
        level: .beginner,
        format: .narrative,
        voice: .male
    )
}

@Model
final class PodcastTask {
    var topic: String
    var configuration: PodcastConfiguration // Holds the user's request/config
    var status: TaskStatus.RawValue
    var currentAction: TaskAction.RawValue?
    var currentProgressValue: Double?
    var audioURL: URL?

    init(topic: String,
         configuration: PodcastConfiguration,
         status: TaskStatus,
         currentAction: TaskAction? = nil,
         currentProgressValue: Double? = nil,
         audioURL: URL? = nil
    ) {
        self.topic = topic
        self.configuration = configuration
        self.status = status.rawValue
        self.currentAction = currentAction?.rawValue
        self.currentProgressValue = currentProgressValue
        self.audioURL = audioURL
    }

    convenience init(topic: String,
                     length: PodcastLength,
                     level: PodcastLevel,
                     format: PodcastFormat,
                     voice: PodcastVoice,
                     status: TaskStatus,
                     currentAction: TaskAction? = nil,
                     currentProgressValue: Double? = nil,
                     audioURL: URL? = nil
    ) {
        let config = PodcastConfiguration(length: length, level: level, format: format, voice: voice)
        self.init(topic: topic,
                  configuration: config,
                  status: status,
                  currentAction: currentAction,
                  currentProgressValue: currentProgressValue,
                  audioURL: audioURL)
    }

    @MainActor
    static let sampleData: [PodcastTask] = [
        PodcastTask(topic: "The Future of Renewable Energy",
                    configuration: PodcastConfiguration(length: .long, level: .intermediate, format: .narrative, voice: .male),
                    status: .pending),

        PodcastTask(topic: "Deep Dive into Quantum Computing",
                    length: .short,
                    level: .expert,
                    format: .narrative,
                    voice: .female,
                    status: .active,
                    currentAction: .research,
                    currentProgressValue: 0.25),

        PodcastTask(topic: "History of Egypt",
                    configuration: PodcastConfiguration(length: .medium, level: .beginner, format: .narrative, voice: .male),
                    status: .active,
                    currentAction: .compose,
                    currentProgressValue: 0.60),

        PodcastTask(topic: "Mastering Personal Finance in Your 20s",
                    length: .long,
                    level: .beginner,
                    format: .conversational,
                    voice: .female,
                    status: .completed,
                    currentAction: nil,
                    currentProgressValue: 1.0,
                    audioURL: URL(string: "https://example.com/podcast/finance.mp3")), // Example audio URL

        PodcastTask(topic: "The Impact of Social Media on Mental Health",
                    configuration: PodcastConfiguration(length: .short, level: .intermediate, format: .narrative, voice: .male),
                    status: .active,
                    currentAction: .voice,
                    currentProgressValue: 0.90),

        PodcastTask(topic: "Beginner's Guide to Astrophotography",
                    configuration: PodcastConfiguration(length: .medium, level: .beginner, format: .conversational, voice: .female),
                    status: .pending),

        PodcastTask(topic: "Advanced AI Ethics Discussion",
                    length: .long,
                    level: .expert,
                    format: .conversational,
                    voice: .male,
                    status: .cancelled, // Added a cancelled example
                    currentAction: .research, // Could be the last action before cancellation
                    currentProgressValue: 0.10)
    ]
}

enum TaskStatus: Int, Codable, CaseIterable {
    case pending
    case active
    case completed
    case cancelled
    
    var description: String {
        switch self {
        case .pending:
            return "Pending"
        case .active:
            return "Active"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
    
}

enum TaskAction: Int, Codable, CaseIterable {
    case research
    case compose
    case voice
    
    var description: String {
        switch self {
        case .research:
            return "Researching"
        case .compose:
            return "Composing the script"
        case .voice:
            return "Voicing"
        }
    }
}

enum PodcastLength: String, Identifiable, CaseIterable, Codable {
    case short = "Bite-sized"
    case medium = "Standard"
    case long = "Extended"

    var id: Self { self }

    var description: String {
        switch self {
        case .short:
            return "\(self.rawValue) (< 5 min)"
        case .medium:
            return "\(self.rawValue) (5-15 min)"
        case .long:
            return "\(self.rawValue) (15+ min)"
        }
    }
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

