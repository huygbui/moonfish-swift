//
//  PodcastRequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCard: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.backendClient) private var client: BackendClient
    var viewModel: PodcastViewModel
    var podcast: Podcast
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card title
                Text(podcast.title)
                    .font(.body)
                    .lineLimit(1)
                
                // Card subtitle
                Text("\(podcast.formattedDate) • \(podcast.details)")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                Button {
                    Task {
                        await viewModel.playPause(
                            audioPlayer: audioPlayer,
                            client: client,
                            modelContext: context
                        )
                    }
                } label: {
                    Image(systemName: viewModel.isPlaying(using: audioPlayer)
                           ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                Text(podcast.formattedDuration)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                PodcastCardMenu(viewModel: viewModel).foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .font(.caption)
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview(traits: .audioPlayerTrait) {
    @Previewable @Environment(AudioPlayer.self) var audioPlayer
    @Previewable @Environment(\.backendClient) var client: BackendClient
    @Previewable @Environment(\.modelContext) var modelContext: ModelContext
    
    let podcast = Podcast(
        taskId: 0,
        topic: "Sustainable Urban Gardening",
        length: PodcastLength.medium.rawValue,
        level: PodcastLevel.intermediate.rawValue,
        format: PodcastFormat.conversational.rawValue,
        voice: PodcastVoice.female.rawValue,
        title: "Beginner's Guide to Gardening in the Far East",
        summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
//        transcript: "Welcome to your first step into gardening! This podcast, made just for you, will cover the basics...",
        fileName: "gardening_beginner.mp3",
        duration: 620, // about 10 minutes
        createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600) // Created an hour after the request
    )
    
    let viewModel = PodcastViewModel.init(podcast: podcast)
    
    ZStack {
        Color(.secondarySystemBackground)
        
        PodcastCard(viewModel: viewModel, podcast: podcast)
    }
    .ignoresSafeArea()
}
