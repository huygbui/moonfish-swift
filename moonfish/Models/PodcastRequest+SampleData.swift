//
//  PodcastRequest+SampleData.swift
//  moonfish
//
//  Created by Huy Bui on 14/5/25.
//
// File: PodcastRequest+SampleData.swift

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
            // 1. Pending Request (using default title and createdDate)
            PodcastRequest(
                id: 0,
                configuration: gardeningConfig,
                createdAt: Date(timeIntervalSinceNow: -86400 * 4), // 3 days ago
                updatedAt: Date(timeIntervalSinceNow: -86400 * 2) // 3 days ago
                // title defaults to "Untitled"
                // createdDate defaults to Date()
            ),

            // 2. Active Request (specific title and older createdDate)
            PodcastRequest(
                id: 1,
                status: .active,
                progressValue: 0.25,
                configuration: quantumConfig,
                createdAt: Date(timeIntervalSinceNow: -86400 * 3), // 3 days ago
                updatedAt: Date(timeIntervalSinceNow: -86400 * 3), // 3 days ago
                title: "Exploring Quantum Realms",
                step: .research
            ),
            
            // 3. Completed Request WITH a completed Podcast
            PodcastRequest(
                id: 2,
                status: .completed,
                progressValue: 1.0,
                configuration: quantumConfig,
                createdAt: Date(timeIntervalSinceNow: -86400 * 5), // 5 days ago
                updatedAt: Date(timeIntervalSinceNow: -86400 * 4), // 4 days ago
                title: "Quantum Leap for Beginners", // Title for the request
                step: .voice,
                completedPodcast: Podcast(
                    title: "Quantum Leap for Beginners", // Title for the actual podcast
                    summary: "A bite-sized intro to quantum physics generated via this request.",
                    transcript: "Welcome! This podcast, born from a request, explores quantum wonders...",
                    audioURL: URL(string: "https://example.com/audio/quantum_from_request.mp3")!,
                    duration: 305,
                    createdAt: Date(timeIntervalSinceNow: -86400 * 5 + 3600), // Podcast created slightly after request
                    configuration: quantumConfig
                )
            ),

            // 4. Another Active Request (default title, recent createdDate)
            PodcastRequest(
                id: 3,
                status: .active,
                progressValue: 0.60,
                configuration: aiEthicsConfig,
                createdAt: Date(timeIntervalSinceNow: -3600 * 2), // 2 hours ago
                updatedAt: Date(timeIntervalSinceNow: -3600 * 2), // 2 hours ago
                // title defaults to "Untitled"
                step: .compose
            ),

            // 5. Cancelled Request (specific title)
            PodcastRequest(
                id: 4,
                status: .cancelled,
                progressValue: 0.45,
                configuration: gardeningConfig,
                createdAt: Date(timeIntervalSinceNow: -86400), // 1 day ago
                updatedAt: Date(timeIntervalSinceNow: -86400), // 1 day ago
                title: "Gardening Podcast",
                step: .compose
            ),
            
            // 6. Completed Request that results in a different Podcast
            PodcastRequest(
                id: 5,
                status: .completed,
                progressValue: 1.0,
                configuration: gardeningConfig,
                createdAt: Date(timeIntervalSinceNow: -86400 * 2), // 2 days ago
                updatedAt: Date(timeIntervalSinceNow: -86400 * 2), // 2 days ago
                title: "Urban Gardening Success",
                step: .voice,
                completedPodcast: Podcast(
                    title: "Urban Gardening Success",
                    summary: "Your guide to a thriving city garden, from a completed request.",
                    transcript: "Hello green thumbs! This podcast, created from your request, helps you grow...",
                    audioURL: URL(string: "https://example.com/audio/gardening_from_request.mp3")!,
                    duration: 950,
                    createdAt: Date(timeIntervalSinceNow: -86400 * 2 + (3600*2)), // Podcast created slightly after request
                    configuration: gardeningConfig
                )
            ),

            // 7. Another Pending Request (specific title, very recent)
            PodcastRequest(
                id: 6,
                configuration: aiEthicsConfig,
                createdAt: Date(timeIntervalSinceNow: -60 * 10), // 10 minutes ago
                updatedAt: Date(timeIntervalSinceNow: -60 * 10), // 10 minutes ago
                title: "Quick Thought on AI"
            )
        ]
    }
}
