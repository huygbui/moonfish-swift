//
//  MiniPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PlayerMini: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(PodcastViewModel.self) private var viewModel
    
    @State private var isPresented = false
    
    var body: some View {
        if let podcast = audioPlayer.currentPodcast {
            HStack(spacing: 12) {
                Text(audioPlayer.currentPodcast?.title ?? "")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.refreshAudioURL(
                            podcast,
                            modelContext: context
                        )
                        audioPlayer.toggle(podcast)
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
                if let podcast = audioPlayer.currentPodcast {
                    PlayerFull(podcast: podcast)
                }
            }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PlayerMini()
}
