//
//  MiniPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PlayerMini: View {
    var episode: Episode
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(AudioManager.self) private var audioPlayer
    @Environment(AuthManager.self) private var authManager
    @Environment(EpisodeViewModel.self) private var viewModel
    
    @State private var isPresented = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(episode.title)
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.refreshAudioURL(
                        episode,
                        modelContext: context,
                        authManager: authManager
                    )
                    audioPlayer.toggle(episode)
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
            if let episode = audioPlayer.currentEpisode {
                PlayerFull(episode: episode)
            }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PlayerMini(episode: .preview)
}
