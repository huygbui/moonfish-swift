//
//  PodcastCardHighlight.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeHighlight: View {
    var episode: Episode
    
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(AuthManager.self) private var authManager
    @Environment(AudioManager.self) private var audioManager
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header
            episodeCover
                .padding(.top, 16)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(episode.title ?? "")
                    .font(.footnote)
                    .lineLimit(1)
                
                (Text(episode.duration?.hoursMinutes ?? "") + Text(" • ") +
                 Text(episode.summary ?? ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3, reservesSpace: true)
            }
            
            // Card footer
            HStack(spacing: 8) {
                playButton
                
                Spacer()
                
                downloadIndicator
                
                EpisodeMenu(episode: episode)
            }
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 256)
        .background(Color(.tertiarySystemFill), in: .rect(cornerRadius: 16))
    }
    
    @ViewBuilder
    private var episodeCover: some View {
        if let cover = episode.cover {
            EpisodeCover(
                pattern: cover,
                size: 160,
                padding: 16
            )
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemFill))
                .frame(width: 160, height: 160)
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
    ZStack {
//        Color(.secondarySystemBackground)
        
        EpisodeHighlight(episode: .preview)
    }
    .ignoresSafeArea()
}

