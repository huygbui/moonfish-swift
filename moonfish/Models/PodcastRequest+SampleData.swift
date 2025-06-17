//
//  PodcastRequest+SampleData.swift
//  moonfish
//
//  Created by Huy Bui on 14/5/25.
//
// File: PodcastRequest+SampleData.swift

import Foundation
import SwiftData

@MainActor
extension PodcastRequest {
    static var sampleData: [PodcastRequest] {
        // --- Define configurations to be used by requests and their resulting podcasts ---
        let quantumConfig = PodcastConfiguration(
            topic: "Introduction to Quantum Physics",
            length: .short,
            level: .beginner,
            format: .narrative,
            voice: .male
        )
        
        let gardeningConfig = PodcastConfiguration(
            topic: "Sustainable Urban Gardening",
            length: .medium,
            level: .intermediate,
            format: .conversational,
            voice: .female
        )

        let aiEthicsConfig = PodcastConfiguration(
            topic: "The Future of AI Ethics",
            length: .long,
            level: .advanced,
            format: .narrative,
            voice: .male
        )

        // --- Sample PodcastRequest instances ---
        return [
            // 1. Completed Request (previously pending)
            PodcastRequest(
                id: 0,
                status: .completed,
                progressValue: 1.0,
                configuration: gardeningConfig,
                createdAt: Date(timeIntervalSinceNow: -86400 * 6), // 6 days ago
                updatedAt: Date(timeIntervalSinceNow: -86400 * 5), // 5 days ago
                step: .voice,
                completedPodcast: Podcast(
                    taskId: 0,
                    configuration: gardeningConfig,
                    title: "Beginner's Guide to Gardening in the Far East",
                    summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
                    transcript: "Welcome to your first step into gardening! This podcast, made just for you, will cover the basics...",
                    audioURL: URL(string: "https://example.com/audio/gardening_beginner.mp3")!,
                    duration: 620, // about 10 minutes
                    createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600), // Created an hour after the request
                    isFavorite: true,
                    isDownloaded: true
                )
            ),

            // 2. Active Request, well in progress
            PodcastRequest(
                id: 1,
                status: .active,
                progressValue: 0.75,
                configuration: quantumConfig,
                createdAt: Date(timeIntervalSinceNow: -3600 * 5), // 5 hours ago
                updatedAt: Date(timeIntervalSinceNow: -3600 * 1), // 1 hour ago
                step: .compose
            ),
            
            // 3. Completed Request
            PodcastRequest(
                id: 2,
                status: .completed,
                progressValue: 1.0,
                configuration: quantumConfig,
                createdAt: Date(timeIntervalSinceNow: -86400 * 5), // 5 days ago
                updatedAt: Date(timeIntervalSinceNow: -86400 * 4), // 4 days ago
                step: .voice,
                completedPodcast: Podcast(
                    taskId: 2,
                    configuration: quantumConfig,
                    title: "Quantum Leap for Beginners",
                    summary: "A bite-sized intro to quantum physics generated via this request.",
                    transcript: "Welcome! This podcast, born from a request, explores quantum wonders...",
                    audioURL: URL(string: "https://example.com/audio/quantum_from_request.mp3")!,
                    duration: 305,
                    createdAt: Date(timeIntervalSinceNow: -86400 * 5 + 3600) // Podcast created slightly after request
                )
            ),

            // 4. Another Completed Request (previously active)
            PodcastRequest(
                id: 3,
                status: .completed,
                progressValue: 1.0,
                configuration: aiEthicsConfig,
                createdAt: Date(timeIntervalSinceNow: -86400 * 10), // 10 days ago
                updatedAt: Date(timeIntervalSinceNow: -86400 * 9),  // 9 days ago
                step: .voice,
                completedPodcast: Podcast(
                    taskId: 3,
                    configuration: aiEthicsConfig,
                    title: "Ethical AI in Modern Society",
                    summary: "A deep dive into the ethical dilemmas and future of Artificial Intelligence.",
                    transcript: "In an age of rapid technological advancement, we must ask: what are the ethics of AI? This podcast, generated from your request, explores this very question...",
                    audioURL: URL(string: "https://example.com/audio/ai_ethics_deep_dive.mp3")!,
                    duration: 1815, // about 30 minutes
                    createdAt: Date(timeIntervalSinceNow: -86400 * 10 + 7200) // Created 2 hours after the request
                )
            ),

            // 5. Cancelled Request
            PodcastRequest(
                id: 4,
                status: .cancelled,
                progressValue: 0.45,
                configuration: gardeningConfig,
                createdAt: Date(timeIntervalSinceNow: -86400), // 1 day ago
                updatedAt: Date(timeIntervalSinceNow: -86400), // 1 day ago
                step: .compose
            ),
            
            // 6. A third Completed Request
            PodcastRequest(
                id: 5,
                status: .completed,
                progressValue: 1.0,
                configuration: gardeningConfig,
                createdAt: Date(timeIntervalSinceNow: -86400 * 2), // 2 days ago
                updatedAt: Date(timeIntervalSinceNow: -86400 * 2), // 2 days ago
                step: .voice,
                completedPodcast: Podcast(
                    taskId: 5,
                    configuration: gardeningConfig,
                    title: "Urban Gardening Success",
                    summary: "Your guide to a thriving city garden, from a completed request.",
                    transcript: "Hello green thumbs! This podcast, created from your request, helps you grow...",
                    audioURL: URL(string: "https://example.com/audio/gardening_from_request.mp3")!,
                    duration: 950,
                    createdAt: Date(timeIntervalSinceNow: -86400 * 2 + (3600*2)), // Podcast created slightly after request
                    isFavorite: true
                )
            ),

            // 7. Pending Request (very recent)
            PodcastRequest(
                id: 6,
                // status defaults to .pending
                configuration: aiEthicsConfig,
                createdAt: Date(timeIntervalSinceNow: -60 * 10), // 10 minutes ago
                updatedAt: Date(timeIntervalSinceNow: -60 * 10), // 10 minutes ago
            )
        ]
    }
}
