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
    @Environment(AudioManager.self) private var audioManager
    @Environment(\.modelContext) private var context: ModelContext
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header
            PodcastAsyncImage(url: episode.podcast.imageURL)
                .frame(width: 160, height: 160)
                .cornerRadius(16)
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
        .background(gradient, in: .rect(cornerRadius: 16))
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
    ZStack {
//        Color(.secondarySystemBackground)
        
        EpisodeHighlight(episode: .previewCompleted)
    }
    .ignoresSafeArea()
}

