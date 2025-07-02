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
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemFill))
                .frame(width: 160, height: 160)
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
                    Label (
                        audioManager.isPlaying(episode) ? "Pause" : "Play",
                        systemImage: audioManager.isPlaying(episode)
                          ? "pause.fill" : "play.fill"
                    )
                    .font(.footnote)
                }
                .buttonStyle(.bordered)
                
                if audioManager.isPlaying(episode) {
                    ProgressView(value: 0.5)
                        .frame(width: 48)
                }
                
                Spacer()
                
                Group {
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
                .frame(width: 16, height: 16)
                .foregroundStyle(.secondary)
                
                
                EpisodeMenu(episode: episode)
                    .foregroundStyle(.secondary)
                    .frame(width: 16, height: 16)
            }
            .foregroundStyle(.primary)
        }
        .padding(16)
        .frame(width: 256)
        .background(Color(.tertiarySystemFill), in: .rect(cornerRadius: 16))
    }
}

#Preview(traits: .audioPlayerTrait) {
    ZStack {
//        Color(.secondarySystemBackground)
        
        EpisodeHighlight(episode: .preview)
    }
    .ignoresSafeArea()
}

