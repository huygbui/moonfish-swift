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
        VStack(alignment: .leading) {
            // Card header
            VStack(alignment: .leading, spacing: 8) {
                Text(episode.title ?? "")
                    .lineLimit(2)
                
                (Text(episode.duration?.hoursMinutes ?? "") +
                 Text(" • ") +
                 Text(episode.summary ?? "")
                    .foregroundStyle(.secondary)
                )
                    .font(.subheadline)
                    .lineLimit(3)
                
                HStack(spacing: 12) {
                    if episode.isNew {
                        Text("New").font(.footnote)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .foregroundStyle(.primary)
                            .background(.primary, in: .capsule.stroke(lineWidth: 1))
                    }
                    
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
                }
            }
            
            Spacer()
            
            // Card footer
            HStack(spacing: 16) {
                Spacer()
                
                EpisodeMenu(episode: episode)
                    .foregroundStyle(.secondary)
                
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
            }
            .foregroundStyle(.primary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
        .frame(width: 256, height: 256)
    }
}

#Preview(traits: .audioPlayerTrait) {
    ZStack {
        Color(.secondarySystemBackground)
        
        EpisodeHighlight(episode: .preview)
    }
    .ignoresSafeArea()
}

