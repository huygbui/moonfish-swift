//
//  MiniPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct MiniPlayer: View {
    @Bindable var audioPlayer: AudioPlayer
    @State private var isPresented = false
    
    var body: some View {
        if let currentPodcast = audioPlayer.currentPodcast {
            HStack(spacing: 12) {
                Text(currentPodcast.title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: { audioPlayer.toggle(currentPodcast) }) {
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
                FullPlayer(audioPlayer: audioPlayer)
            }
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
        summary: "A simple guide to get you started with urban gardening.",
        transcript: "Welcome to your first step into gardening!",
        audioURL: URL(string: "https://example.com/audio/gardening_beginner.mp3")!,
        duration: 620,
        createdAt: Date(),
        configuration: gardeningConfig
    )
    let audioPlayer = AudioPlayer(currentPodcast: podcast, isPlaying: true)
    
    MiniPlayer(audioPlayer: audioPlayer)
}
