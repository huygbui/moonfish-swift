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
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card title
                Text(episode.title ?? "")
                    .font(.body)
                    .lineLimit(1)
                
                // Card subtitle
                Text("""
                    \(episode.createdAt.compact) • \
                    \(episode.length.localizedCapitalized), \
                    \(episode.level.localizedCapitalized)
                    """
                )
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                Button {
                    Task {
                        await rootModel.refreshAudioURL(
                            episode,
                            modelContext: context,
                            authManager: authManager
                        )
                        
                        audioManager.toggle(episode)
                    }
                } label: {
                    Image(systemName: audioManager.isPlaying(episode)
                          ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                }
                .foregroundStyle(.primary)
                
                Text(episode.duration?.hoursMinutes ?? "")
                    .font(.caption)
                
                Spacer()
                
                
                ZStack {
                    if episode.isDownloaded {
                        Image(systemName: "checkmark.circle")
                    } else if episode.downloadState == .downloading {
                        GaugeProgress(
                            fractionCompleted: episode.downloadProgress,
                            strokeWidth: 1
                        )
                    } else {
                        EmptyView()
                    }
                }
                .frame(width: 16, height: 16)
                .foregroundStyle(.secondary)
                
                EpisodeMenu(episode: episode)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
        }
    }
}


#Preview(traits: .audioPlayerTrait) {
    ZStack {
        Color(.secondarySystemBackground)
        EpisodeRow(episode: .preview)
    }
    .ignoresSafeArea()
}

