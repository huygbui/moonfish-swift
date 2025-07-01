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
                HStack(spacing: 4) {
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
                              ? "pause.circle" : "play.circle.fill")
                        .font(.title)
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
