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
    @Environment(AudioManager.self) private var audioPlayer
    @Environment(EpisodeViewModel.self) private var viewModel
    
    @State private var isPresented = false
    
    var body: some View {
        HStack(spacing: 16) {
            Text(audioPlayer.currentEpisode?.title ?? "No podcast playing")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer(minLength: 0)
            
            Group {
                Button {
                    audioPlayer.toggle()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                }
                // Forward 15 seconds
                Button(action: audioPlayer.skipForward) {
                    Image(systemName: "goforward.15")
                }
            }
            .font(.title3)
            .foregroundStyle(.primary)
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
    PlayerMini()
}
