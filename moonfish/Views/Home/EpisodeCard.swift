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
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemFill))
                .frame(width: 96, height: 96)
            
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
                    .lineLimit(2)
                
                Spacer()
                
                // Card footer
                HStack(spacing: 8) {
                    playButton
                    
                    Spacer()
                    
                    downloadIndicator
                    
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
        Button(action: onPlayButtonTap) {
            if audioManager.currentEpisode != episode {
                if audioManager.isPlaying(episode) {
                    HStack {
                        Image(systemName: "pause.fill")
                        ProgressView(value: audioManager.currentProgress)
                            .frame(width: 36)
                        Text(audioManager.timeRemaining.hoursMinutesCompact)
                    }
                } else {
                    HStack {
                        Image(systemName: "play.fill")
                        Text(episode.duration?.hoursMinutesCompact ?? "")
                    }
                }
            } else {
                HStack {
                    Image(systemName: audioManager.isPlaying(episode) ? "pause.fill" : "play.fill")
                    ProgressView(value: audioManager.currentProgress)
                        .frame(width: 36)
                    Text(audioManager.timeRemaining.hoursMinutesCompact)
                }
            }
            
        }
        .font(.caption)
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
    }
    
    private func onPlayButtonTap() {
        Task {
            await rootModel.refreshAudioURL(
                episode,
                modelContext: context,
                authManager: authManager
            )
            
            audioManager.toggle(episode)
        }
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
