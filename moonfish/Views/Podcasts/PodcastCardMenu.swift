//
//  CardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCardMenu: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.backendClient) private var client: BackendClient
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteAlert = false
    
    var viewModel: PodcastViewModel
    
    var body: some View {
        Menu {
            Button {
                viewModel.toggleFavorite()
            } label: {
                HStack {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    Text(viewModel.isFavorite ? "Remove Favorite" : "Add to Favorites")
                }
            }
            
            Button {
                viewModel.downloadPodcast()
            } label: {
                HStack {
                    Image(systemName: viewModel.isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle")
                    Text(viewModel.isDownloaded ? "Remove Download" : "Download Episode")
                }
            }
            
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Episode")
                }
            }
           
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
                .frame(width: 24, height: 24)
                .background(Color(.tertiarySystemBackground), in: .circle)
        }
        .alert("Delete Episode", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel
                        .deletePodcast(
                            audioPlayer: audioPlayer,
                            client: client,
                            modelContext: context
                        )
                }
                dismiss()
            }
        } message: {
            Text("This episode will be deleted forever.")
        }
    }
}

#Preview(traits: .audioPlayer) {
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
    
    PodcastCardMenu(viewModel: viewModel)
}
