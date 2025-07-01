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
    @Environment(AudioManager.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header
            HStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemFill))
                    .frame(width: 160, height: 160)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.title ?? "")
                    .font(.footnote)
                    .lineLimit(1)
                
                (Text(episode.duration?.hoursMinutes ?? "") +
                 Text(" • ") +
                 Text(episode.summary ?? "")
                )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3, reservesSpace: true)
            }
            
            Spacer(minLength: 0)
            
            // Card footer
            HStack(spacing: 12) {
                Button {
                    Task {
                        await rootModel.refreshAudioURL(
                            episode,
                            modelContext: context,
                            authManager: authManager
                        )
                        audioPlayer.toggle(episode)
                    }
                } label: {
                    Image(systemName: audioPlayer.isPlaying(episode)
                          ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                }
                
                
                Spacer()
                
                Group {
                    if episode.isDownloaded {
                        Image(systemName: "checkmark.circle")
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
        .padding()
        .frame(width: 240, height: 360)
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

