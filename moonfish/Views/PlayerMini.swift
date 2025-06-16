//
//  MiniPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct PlayerMini: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    @State private var isPresented = false
    
    var body: some View {
        if let currentPodcast = audioPlayer.currentPodcast {
            HStack(spacing: 12) {
                Text(currentPodcast.title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: { audioPlayer.togglePlayback() }) {
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
                PlayerFull()
            }
        }
    }
}

#Preview(traits: .audioPlayer) {
    PlayerMini()
}
