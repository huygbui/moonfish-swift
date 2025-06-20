//
//  PodcastRequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCard: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.backendClient) private var client: BackendClient
    var viewModel: PodcastViewModel
    var podcast: Podcast
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card title
                Text(podcast.title)
                    .font(.body)
                    .lineLimit(1)
                
                // Card subtitle
                (Text(podcast.duration.hoursMinutes) +
                 Text(" • ") +
                 Text(podcast.details))
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
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
                Text(podcast.formattedDuration)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                PodcastCardMenu(viewModel: viewModel).foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .font(.caption)
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview(traits: .audioPlayerTrait) {
    let viewModel = PodcastViewModel.init(podcast: .preview)
    
    ZStack {
        Color(.secondarySystemBackground)
        PodcastCard(viewModel: viewModel, podcast: .preview)
    }
    .ignoresSafeArea()
}
