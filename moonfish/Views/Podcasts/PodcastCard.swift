//
//  PodcastRequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCard: View {
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(EpisodeViewModel.self) private var rootModel
    var podcast: Podcast
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card title
                Text(podcast.title)
                    .font(.body)
                    .lineLimit(1)
                
                // Card subtitle
                Text("""
                    \(podcast.createdAt.compact) • \
                    \(podcast.length.localizedCapitalized), \
                    \(podcast.format.localizedCapitalized), \
                    \(podcast.level.localizedCapitalized)
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
                            podcast,
                            modelContext: context,
                            authManager: authManager
                        )
                        
                        audioManager.toggle(podcast)
                    }
                } label: {
                    Image(systemName: audioManager.isPlaying(podcast)
                          ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                }
                .foregroundStyle(.primary)
                
                Text(podcast.duration.hoursMinutes)
                    .font(.caption)
                
                Spacer()
                
                
                ZStack {
                    if podcast.isDownloaded {
                        Image(systemName: "checkmark.circle")
                    } else if podcast.downloadState == .downloading {
                        GaugeProgress(
                            fractionCompleted: podcast.downloadProgress,
                            strokeWidth: 1
                        )
                    } else {
                        EmptyView()
                    }
                }
                .frame(width: 16, height: 16)
                .foregroundStyle(.secondary)
                
                PodcastCardMenu(podcast: podcast)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}


#Preview(traits: .audioPlayerTrait) {
    ZStack {
        Color(.secondarySystemBackground)
        PodcastCard(podcast: .preview)
    }
    .ignoresSafeArea()
}
