//
//  MiniPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PlayerMini: View {
    var viewModel: PodcastViewModel
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.backendClient) private var client: BackendClient
    @Environment(\.modelContext) private var context: ModelContext
    @State private var isPresented = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(audioPlayer.currentPodcast?.title ?? "")
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.playPause(
                        audioPlayer: audioPlayer,
                        client: client,
                        modelContext: context
                    )
                }
            } label: {
                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
            }
            
            // Forward 15 seconds
            Button(action: audioPlayer.skipForward) {
                Image(systemName: "goforward.15")
            }
        }
        .padding(.horizontal, 16)
        .onTapGesture { isPresented.toggle() }
        .sheet(isPresented: $isPresented) {
            PlayerFull(viewModel: viewModel)
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
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
    let viewModel = PodcastViewModel(podcast: podcast)
    
    PlayerMini(viewModel: viewModel)
}
