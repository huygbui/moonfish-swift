//
//  EpisodeRow.swift
//  moonfish
//
//  Created by Huy Bui on 29/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeRow: View {
    let episode: Episode
    
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 16) {
                title
                Spacer()
                cover
            }
            
            HStack {
                playButton
                timeRemaining
                Spacer()
                downloadIndicator
                menuButton
            }
        }
    }
    
    private var title: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Subtitle
            Text("\(episode.createdAt.compact) • \(episode.level.localizedCapitalized)")
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(.secondary)
            
            // Title
            Text(episode.title ?? "")
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var cover: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.tertiarySystemFill))
            .frame(width: 80, height: 80)
    }
    
    @ViewBuilder
    private var timeRemaining: some View {
        switch episode.status {
        case EpisodeStatus.pending.rawValue:
            Text("Pending...")
                .font(.caption)
                .shimmer()
        case EpisodeStatus.active.rawValue:
            Text(episode.currentStep)
                .font(.caption)
                .shimmer()
        default:
            Text(episode.duration?.hoursMinutes ?? "")
                .font(.caption)
        }
    }
    
    @ViewBuilder
    private var playButton: some View {
        if episode.status == EpisodeStatus.completed.rawValue {
            Button(action: handlePlayButtonTap) {
                Image(systemName: audioManager.isPlaying(episode)
                      ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        } else {
            GaugeProgress(fractionCompleted: episode.currentProgress, strokeWidth: 4)
                .frame(width: 32, height: 32)
        }
    }
    
    private var downloadIndicator: some View {
        ZStack {
            if episode.isDownloaded {
                Image(systemName: "checkmark.circle")
            } else if episode.downloadState == .downloading {
                GaugeProgress(
                    fractionCompleted: episode.downloadProgress,
                    strokeWidth: 1
                )
            }
        }
        .font(.caption)
        .frame(width: 16, height: 16)
        .foregroundStyle(.secondary)
    }
   
    @ViewBuilder
    private var menuButton: some View {
        if episode.isCompleted {
            EpisodeMenu(episode: episode)
                .foregroundStyle(.secondary)
        } else {
            OngoingEpisodeMenu(episode: episode)
                .foregroundStyle(.secondary)
        }
    }
    
    private func handlePlayButtonTap() {
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
        Color(.secondarySystemBackground)
        EpisodeRow(episode: .preview)
            .padding()
    }
    .ignoresSafeArea()
}

