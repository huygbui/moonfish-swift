//
//  CardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct PodcastCardMenu: View {
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
    
    PodcastCardMenu(podcast: podcast)
}
