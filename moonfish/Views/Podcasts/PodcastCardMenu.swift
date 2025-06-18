//
//  CardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCardMenu: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.backendClient) private var client: BackendClient
    @Environment(AudioPlayer.self) private var audioPlayer
    var podcast: Podcast
    
    var body: some View {
        Menu {
            Button {
                podcast.isFavorite.toggle()
            } label: {
                HStack {
                    Image(systemName: podcast.isFavorite ? "heart.fill" : "heart")
                    
                    Text(podcast.isFavorite ? "Liked" : "Like")
                }
            }
            
            Button {
                podcast.isDownloaded.toggle()
            } label: {
                HStack {
                    Image(systemName: podcast.isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle")
                    Text(podcast.isDownloaded ? "Downloaded" : "Download")
                }
            }
            
            Button(role: .destructive) {
                Task {
                    await deletePodcast()
                }
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
           
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
                .frame(width: 24, height: 24)
                .background(Color(.tertiarySystemBackground), in: .circle)
        }
    }
    
    func deletePodcast() async {
        do {
            if podcast == audioPlayer.currentPodcast {
                audioPlayer.pause()
                audioPlayer.currentPodcast = nil
            }
            modelContext.delete(podcast)
            try await client.deletePodcast(id: podcast.taskId)
        } catch {
            print("Failed to delete podcast: \(error)")
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
    
    PodcastCardMenu(podcast: podcast)
}
