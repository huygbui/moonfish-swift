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
        return [
            Podcast(
                taskId: 0,
                topic: "Sustainable Urban Gardening",
                length: PodcastLength.medium.rawValue,
                level: PodcastLevel.intermediate.rawValue,
                format: PodcastFormat.conversational.rawValue,
                voice: PodcastVoice.female.rawValue,
                title: "Beginner's Guide to Gardening in the Far East",
                summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
//                transcript: "Welcome to your first step into gardening! This podcast, made just for you, will cover the basics...",
                fileName: "gardening_beginner.mp3",
                duration: 620, // about 10 minutes
                createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600), // Created an hour after the request
                isFavorite: true,
            ),
            
            Podcast(
                taskId: 2,
                topic: "Introduction to Quantum Physics",
                length: PodcastLength.short.rawValue,
                level: PodcastLevel.beginner.rawValue,
                format: PodcastFormat.narrative.rawValue,
                voice: PodcastVoice.male.rawValue,
                title: "Quantum Leap for Beginners",
                summary: "A bite-sized intro to quantum physics generated via this request.",
//                transcript: "Welcome! This podcast, born from a request, explores quantum wonders...",
                fileName: "quantum_from_request.mp3",
                duration: 305,
                createdAt: Date(timeIntervalSinceNow: -86400 * 5 + 3600) // Podcast created slightly after request
            ),
            
            Podcast(
                taskId: 3,
                topic: "The Future of AI Ethics",
                length: PodcastLength.short.rawValue,
                level: PodcastLevel.beginner.rawValue,
                format: PodcastFormat.narrative.rawValue,
                voice: PodcastVoice.male.rawValue,
                title: "Ethical AI in Modern Society",
                summary: "A deep dive into the ethical dilemmas and future of Artificial Intelligence.",
//                transcript: "In an age of rapid technological advancement, we must ask: what are the ethics of AI? This podcast, generated from your request, explores this very question...",
                fileName: "ai_ethics_deep_dive.mp3",
                duration: 1815, // about 30 minutes
                createdAt: Date(timeIntervalSinceNow: -86400 * 10 + 7200) // Created 2 hours after the request
            ),
            
            Podcast(
                taskId: 5,
                topic: "Sustainable Urban Gardening",
                length: PodcastLength.medium.rawValue,
                level: PodcastLevel.intermediate.rawValue,
                format: PodcastFormat.conversational.rawValue,
                voice: PodcastVoice.female.rawValue,
                title: "Urban Gardening Success",
                summary: "Your guide to a thriving city garden, from a completed request.",
//                transcript: "Hello green thumbs! This podcast, created from your request, helps you grow...",
                fileName: "gardening_from_request.mp3",
                duration: 950,
                createdAt: Date(timeIntervalSinceNow: -86400 * 2 + (3600*2)), // Podcast created slightly after request
                isFavorite: true
            ),
        ]
    }
}
