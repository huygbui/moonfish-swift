//
//  PodcastRequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI

struct PodcastCard: View {
    var podcast: Podcast
    var audioPlayer: AudioPlayer

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading) {
                // Card title
                HStack(spacing: 16) {
                    Text(podcast.title)
                        .font(.body)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                
                // Card subtitle
                HStack {
                    Text(podcast.configuration.length.displayName)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                    Text(podcast.configuration.format.displayName)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                    Text(podcast.configuration.level.displayName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                Button(action: { audioPlayer.toggle(podcast) }) {
                    Image(systemName: audioPlayer.isPlaying && audioPlayer.currentPodcast == podcast ? "pause.circle.fill" :"play.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                Text(Duration.seconds(podcast.duration), format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
               
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview {
    let gardeningConfig = PodcastConfiguration(
        topic: "Sustainable Urban Gardening",
        length: .medium,
        level: .intermediate,
        format: .conversational,
        voice: .female
    )
    let podcast = Podcast(
        title: "Beginner's Guide to Gardening in the Far East",
        summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
        transcript: "Welcome to your first step into gardening! This podcast, made just for you, will cover the basics...",
        audioURL: URL(string: "https://example.com/audio/gardening_beginner.mp3")!,
        duration: 620, // about 10 minutes
        createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600), // Created an hour after the request
        configuration: gardeningConfig
    )
    let audioPlayer = AudioPlayer()
    
    ZStack {
        Color(.secondarySystemBackground)
        
        PodcastCard(podcast: podcast, audioPlayer: audioPlayer)
    }
    .ignoresSafeArea()
}
