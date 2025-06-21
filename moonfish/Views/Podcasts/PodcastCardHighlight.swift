//
//  PodcastCardHighlight.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCardHighlight: View {
    var podcast: Podcast
    
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        VStack(alignment: .leading) {
            // Card header
            VStack(alignment: .leading, spacing: 4) {
                Text(podcast.title)
                    .lineLimit(2)
                
                (Text(podcast.duration.hoursMinutes) +
                 Text(" • ") +
                 Text(podcast.summary)
                    .foregroundStyle(.secondary)
                )
                    .font(.subheadline)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Card footer
            HStack(spacing: 16) {
                Spacer()
                
                PodcastCardMenu(podcast: podcast)
                    .foregroundStyle(.secondary)
                
                Button {
                    Task {
                        await rootModel.refreshAudioURL(
                            podcast,
                            modelContext: context
                        )
                        audioPlayer.toggle(podcast)
                    }
                } label: {
                    Image(systemName: audioPlayer.isPlaying(podcast)
                          ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                }
            }
            .foregroundStyle(.primary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
        .frame(width: 256, height: 256)
    }
}

#Preview(traits: .audioPlayerTrait) {
    ZStack {
        Color(.secondarySystemBackground)
        
        PodcastCardHighlight(podcast: .preview)
    }
    .ignoresSafeArea()
}

