//
//  PodcastDetail.swift
//  moonfish
//
//  Created by Huy Bui on 24/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeDetail: View {
    var episode: Episode
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext

    @State private var isExpanded = false
    
    private let imageDimension: CGFloat = 256
    private let playButtonWidth: CGFloat = 128
    private let playButtonHeight: CGFloat = 48
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                cover
                title
                play
                summary
                details
            }
            .toolbar {
                ToolbarItem { EpisodeMenu(podcast: episode) }
            }
        }
        .safeAreaPadding(.horizontal)
        .scrollIndicators(.hidden)
    }
    
    private var cover: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.tertiary)
            .frame(width: imageDimension, height: imageDimension)
    }
    
    private var title: some View {
        VStack(spacing: 0) {
            Text("\(episode.createdAt.compact) • \(episode.duration.hoursMinutes)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(episode.title)
                .font(.title)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
    }
    
    private var play: some View {
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
                  ? "pause.fill" : "play.fill"
            )
                .frame(width: playButtonWidth, height: playButtonHeight)
                .background(.primary, in: .capsule.stroke(lineWidth: 1))
        }
        .controlSize(.large)
        .buttonStyle(.plain)
    }
    
    private var summary: some View {
        Text(episode.summary)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var details: some View {
        VStack(alignment: .leading) {
            LabeledContent("Format", value: episode.podcast.format.localizedCapitalized)
            Divider()
            LabeledContent("Length", value: episode.length.localizedCapitalized)
            Divider()
            LabeledContent("Level", value: episode.level.localizedCapitalized)
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    EpisodeDetail(episode: .preview)
}
