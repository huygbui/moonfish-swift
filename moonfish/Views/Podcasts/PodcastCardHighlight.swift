//
//  PodcastCardHighlight.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCardHighlight: View {
    var viewModel: PodcastViewModel
    var podcast: Podcast
    
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.backendClient) private var client: BackendClient

    var body: some View {
        VStack(alignment: .leading) {
            // Card header
            VStack(alignment: .leading, spacing: 4) {
                Text(podcast.title)
                
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
                
                PodcastCardMenu(viewModel: viewModel, podcast: podcast).foregroundStyle(.secondary)
                
                Button {
                    Task {
                        await viewModel.playPause(
                            audioPlayer: audioPlayer,
                            client: client,
                            modelContext: context
                        )
                    }
                } label: {
                    Image(systemName: viewModel.isPlaying(using: audioPlayer)
                          ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                }
            }
            .foregroundStyle(.primary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview(traits: .audioPlayerTrait) {
    let podcast: Podcast = .preview
    let viewModel = PodcastViewModel(podcast: podcast)
    
    ZStack {
        Color(.secondarySystemBackground)
        
        PodcastCardHighlight(viewModel: viewModel, podcast: podcast)
            .frame(width: 272, height: 272)
    }
    .ignoresSafeArea()
}

