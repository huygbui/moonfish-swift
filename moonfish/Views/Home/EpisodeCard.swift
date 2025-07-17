//
//  EpisodeCard.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeCard: View {
    let episode: Episode
    
    @Environment(AudioManager.self) private var audioManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            episodeImage
            episodeContent
        }
    }
    
    private var episodeImage: some View {
        PodcastAsyncImage(url: episode.podcast.imageURL)
            .frame(width: 80, height: 80)
            .cornerRadius(8)
    }
    
    private var episodeContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            episodeMetadata
            episodeTitle
            Spacer()
            episodeFooter
        }
    }
    
    private var episodeMetadata: some View {
        Text("\(episode.createdAt.relative) • \(episode.podcast.title)")
            .font(.caption)
            .lineLimit(1)
            .foregroundStyle(.secondary)
    }
    
    private var episodeTitle: some View {
        Text(episode.title ?? "Untitled")
            .font(.footnote)
            .lineLimit(1)
    }
    
    private var episodeFooter: some View {
        HStack(spacing: 8) {
            statusIndicator
            Spacer()
            trailingActions
        }
        .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        switch episode.status {
        case "completed":
            playButton
        case "active":
            Text(episode.currentStep)
                .font(.footnote)
                .shimmer()
        default:
            Text(episode.status?.localizedCapitalized ?? "Failed")
                .font(.footnote)
        }
    }
    
    @ViewBuilder
    private var trailingActions: some View {
        HStack(spacing: 8) {
            switch episode.status {
            case "completed":
                downloadIndicator
                EpisodeMenu(episode: episode)
            case "active", "failed":
                EpisodeMenu(episode: episode)
            default:
                EmptyView()
            }
        }
    }
    
    private var playButton: some View {
        Button(action: { audioManager.toggle(episode) }) {
            HStack(spacing: 6) {
                playIcon
                progressOrDuration
            }
            .frame(height: 16)
        }
        .font(.caption)
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
    }
    
    private var playIcon: some View {
        Image(systemName: audioManager.isPlaying(episode) ? "pause.fill" : "play.fill")
    }
    
    @ViewBuilder
    private var progressOrDuration: some View {
        if audioManager.currentEpisode == episode {
            ProgressView(value: audioManager.currentProgress)
                .frame(width: 36)
            Text(audioManager.timeRemaining.hoursMinutesCompact)
        } else if let duration = episode.duration {
            Text(duration.hoursMinutesCompact)
        }
    }
    
    @ViewBuilder
    private var downloadIndicator: some View {
        switch episode.downloadState {
        case .downloading:
            GaugeProgress(
                fractionCompleted: episode.downloadProgress,
                strokeWidth: 1
            )
        default:
            if episode.isDownloaded {
                Image(systemName: "checkmark.circle")
                    .font(.footnote)
            }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    ScrollView {
        LazyVStack(spacing: 8) {
            EpisodeCard(episode: .previewCompleted)
            Divider()
            EpisodeCard(episode: .previewFailed)
            Divider()
        }
    }
    .contentMargins(.horizontal, 16)
    .scrollIndicators(.hidden)
}
