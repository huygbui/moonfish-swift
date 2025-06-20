//
//  PodcastCardHighlight.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCardHighlight: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.backendClient) private var client: BackendClient
    var viewModel: PodcastViewModel

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(viewModel.title)
                        .lineLimit(2)
                }
                
                
                (Text(viewModel.duration, format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                    .font(.subheadline) +
                 Text(" • ")
                    .font(.subheadline) +
                 Text(viewModel.summary)
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
                    
                    PodcastCardMenu(viewModel: viewModel).foregroundStyle(.secondary)
                    
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
                }
                .foregroundStyle(.primary)
            }
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
    
    let viewModel = PodcastViewModel(podcast: podcast)
    
    ZStack {
        Color(.secondarySystemBackground)
        
        PodcastCardHighlight(viewModel: viewModel)
            .frame(width: 272, height: 272)
    }
    .ignoresSafeArea()
}

