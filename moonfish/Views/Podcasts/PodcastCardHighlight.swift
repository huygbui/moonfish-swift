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
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(viewModel.title)
                        .lineLimit(2)
                }
                
                
                (Text(viewModel.duration, format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                    .font(.subheadline) +
                 Text(" • ")
                    .font(.subheadline) +
                 Text(viewModel.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                )
                .lineLimit(3)
                 
            }
            Spacer()
            
            // Card footer
            VStack(spacing: 16) {
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    PodcastCardMenu(viewModel: viewModel).foregroundStyle(.secondary)
                    
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
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview(traits: .audioPlayerTrait) {
    @Previewable @Environment(AudioPlayer.self) var audioPlayer
    @Previewable @Environment(\.backendClient) var client: BackendClient
    @Previewable @Environment(\.modelContext) var modelContext: ModelContext
    
    let podcast: Podcast = .preview
    
    let viewModel = PodcastViewModel(podcast: podcast)
    
    ZStack {
        Color(.secondarySystemBackground)
        
        PodcastCardHighlight(viewModel: viewModel, podcast: podcast)
            .frame(width: 272, height: 272)
    }
    .ignoresSafeArea()
}

