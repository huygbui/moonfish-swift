//
//  Podcast+SampleData.swift
//  moonfish
//
//  Created by Huy Bui on 17/6/25.
//

import Foundation
import SwiftData

@MainActor
extension Podcast {
    static var sampleData: [Podcast] {
        let podcast = Podcast.preview
        podcast.episodes = [
            Episode(
                serverId: 0,
                topic: "Sustainable Urban Gardening",
                length: EpisodeLength.medium.rawValue,
                level: EpisodeLevel.intermediate.rawValue,
                format: EpisodeFormat.conversational.rawValue,
                voice1: EpisodeVoice.female.rawValue,
                voice2: EpisodeVoice.female.rawValue,
                status: EpisodeStatus.active.rawValue,
                step: EpisodeStep.voice.rawValue,
                title: "Beginner's Guide to Gardening in the Far East",
                summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
                fileName: "gardening_beginner.mp3",
                duration: 620, // about 10 minutes
                createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600), // Created an hour after the request
                isFavorite: true,
                podcast: podcast
            ),
            
            Episode(
                serverId: 2,
                topic: "Introduction to Quantum Physics",
                length: EpisodeLength.short.rawValue,
                level: EpisodeLevel.beginner.rawValue,
                format: EpisodeFormat.narrative.rawValue,
                voice1: EpisodeVoice.male.rawValue,
                status: EpisodeStatus.completed.rawValue,
                title: "Quantum Leap for Beginners",
                summary: "A bite-sized intro to quantum physics generated via this request.",
                fileName: "quantum_from_request.mp3",
                duration: 305,
                createdAt: Date(timeIntervalSinceNow: -86400 * 5 + 3600),
                audioURL: URL(string: "https://example.com/audio/quantum_from_request.mp3")!,
                expiresAt: Date(timeIntervalSinceNow: 86400 * 7),
                podcast: podcast
            ),
            
            Episode(
                serverId: 3,
                topic: "The Future of AI Ethics",
                length: EpisodeLength.short.rawValue,
                level: EpisodeLevel.beginner.rawValue,
                format: EpisodeFormat.narrative.rawValue,
                voice1: EpisodeVoice.male.rawValue,
                status: EpisodeStatus.completed.rawValue,
                title: "Ethical AI in Modern Society",
                summary: "A deep dive into the ethical dilemmas and future of Artificial Intelligence.",
                fileName: "ai_ethics_deep_dive.mp3",
                duration: 1815, // about 30 minutes
                createdAt: Date(timeIntervalSinceNow: -86400 * 10 + 7200), // Created 2 hours after the request
                audioURL: URL(string: "https://example.com/audio/the_future_of_ai_ethics.mp3"),
                expiresAt: Date(timeIntervalSinceNow: 86400 * 7),
                podcast: podcast,
            ),
            
            Episode(
                serverId: 5,
                topic: "Sustainable Urban Gardening",
                length: EpisodeLength.medium.rawValue,
                level: EpisodeLevel.intermediate.rawValue,
                format: EpisodeFormat.conversational.rawValue,
                voice1: EpisodeVoice.female.rawValue,
                voice2: EpisodeVoice.male.rawValue,
                status: EpisodeStatus.completed.rawValue,
                title: "Urban Gardening Success",
                summary: "Your guide to a thriving city garden, from a completed request.",
                fileName: "gardening_from_request.mp3",
                duration: 950,
                createdAt: Date(timeIntervalSinceNow: -86400 * 2 + (3600*2)), // Podcast created slightly after request
                isFavorite: true,
                audioURL: URL(string: "https://example.com/audio/the_future_of_ai_ethics.mp3"),
                expiresAt: Date(timeIntervalSinceNow: 86400 * 7),
                podcast: podcast,
            ),
        ]
        return [podcast]
    }
}
