//
//  MiniPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PlayerMini: View {
    var podcast: Podcast
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(AudioManager.self) private var audioPlayer
    @Environment(AuthManager.self) private var authManager
    @Environment(PodcastViewModel.self) private var viewModel
    
    @State private var isPresented = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(podcast.title)
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.refreshAudioURL(
                        podcast,
                        modelContext: context,
                        authManager: authManager
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
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .onTapGesture { isPresented.toggle() }
        .sheet(isPresented: $isPresented) {
            if let podcast = audioPlayer.currentPodcast {
                PlayerFull(podcast: podcast)
            }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PlayerMini(podcast: .preview)
}
