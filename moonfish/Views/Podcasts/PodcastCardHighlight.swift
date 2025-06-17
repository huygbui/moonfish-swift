//
//  PodcastCardHighlight.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI

struct PodcastCardHighlight: View {
    var podcast: Podcast
    @Environment(AudioPlayer.self) private var audioPlayer

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(podcast.title)
                        .lineLimit(2)
                }
                
                
                (Text(Duration.seconds(podcast.duration), format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                    .font(.subheadline) +
                 Text(" • ")
                    .font(.subheadline) +
                Text(podcast.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                )
                .lineLimit(3)
                 
            }
            Spacer()
            
            // Card footer
            VStack(spacing: 16) {
                
                HStack(spacing: 16) {
                    Spacer()
                    PodcastCardMenu(podcast: podcast).foregroundStyle(.secondary)
                    Button(action: { audioPlayer.toggle(podcast) }) {
                        Image(systemName: audioPlayer.isPlaying && audioPlayer.currentPodcast == podcast ? "pause.fill" :"play.fill")
                            .frame(width: 32, height: 32)
                    }
                    .foregroundStyle(Color(.systemBackground))
                    .background(.primary, in: .circle)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview(traits: .audioPlayer) {
    let gardeningConfig = PodcastConfiguration(
        topic: "Sustainable Urban Gardening",
        length: .medium,
        level: .intermediate,
        format: .conversational,
        voice: .female
    )
    let podcast = Podcast(
        taskId: 0,
        configuration: gardeningConfig,
        title: "Beginner's Guide to Gardening in the Far East",
        summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
        transcript: "Welcome to your first step into gardening! This podcast, made just for you, will cover the basics...",
        audioURL: URL(string: "https://example.com/audio/gardening_beginner.mp3")!,
        duration: 620, // about 10 minutes
        createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600) // Created an hour after the request
    )
    
    ZStack {
        Color(.secondarySystemBackground)
        
        PodcastCardHighlight(podcast: podcast)
            .frame(width: 272, height: 272)
    }
    .ignoresSafeArea()
}

