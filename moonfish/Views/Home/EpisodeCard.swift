//
//  PodcastRequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeCard: View {
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(EpisodeViewModel.self) private var rootModel
    var episode: Episode
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            PodcastAsyncImage(url: episode.podcast.imageURL)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card subtitle
                
                Text(episode.createdAt.relative + " • " + episode.podcast.title)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                
                // Card title
                Text(episode.title ?? "")
                    .font(.footnote)
                    .lineLimit(1)
                
                Spacer()
                
                // Card footer
                HStack(spacing: 8) {
                    playButton
                    
                    Spacer()
                    
                    downloadIndicator
                        .frame(width: 16, height: 16)

                    EpisodeMenu(episode: episode)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var downloadIndicator: some View {
        if episode.isDownloaded {
            Image(systemName: "checkmark.circle")
                .font(.footnote)
        } else if episode.downloadState == .downloading {
            GaugeProgress(
                fractionCompleted: episode.downloadProgress,
                strokeWidth: 1
            )
        }
    }
    
    private var playButton: some View {
        Button(action: { audioManager.toggle(episode) }) {
            HStack(alignment: .center) {
                Image(systemName: audioManager.isPlaying(episode) ? "pause.fill" : "play.fill")
                if audioManager.currentEpisode == episode {
                    ProgressView(value: audioManager.currentProgress)
                        .frame(width: 36)
                    
                    Text(audioManager.timeRemaining.hoursMinutesCompact)
                } else {
                    if let duration = episode.duration {
                        Text(duration.hoursMinutesCompact)
                    }
                }
            }
            .frame(height: 16)
        }
        .font(.caption)
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
    }
}


#Preview(traits: .audioPlayerTrait) {
    ScrollView() {
        VStack(spacing: 8) {
            ForEach(1..<3) { _ in
                EpisodeCard(episode: .preview)
                Divider()
            }
        }
    }
    .contentMargins(.horizontal, 16)
    .scrollIndicators(.hidden)
}
