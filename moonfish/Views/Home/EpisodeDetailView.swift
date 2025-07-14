//
//  PodcastDetail.swift
//  moonfish
//
//  Created by Huy Bui on 24/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeDetailView: View {
    var episode: Episode
    @Environment(AudioManager.self) private var audioManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        content
            .toolbar { ToolbarItem { EpisodeMenu(episode: episode) } }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                cover
                title
                play
                summary
                details
            }
        }
        .safeAreaPadding(.horizontal)
        .scrollIndicators(.hidden)
        .conditionalSafeAreaBottomPadding()
    }
   
    private var cover: some View {
        PodcastAsyncImage(url: episode.podcast.imageURL)
            .frame(width: 160, height: 160)
            .cornerRadius(16)
    }
    
    private var title: some View {
        VStack(spacing: 0) {
            Text("\(episode.createdAt.compact) • \(episode.duration?.hoursMinutes ?? "")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(episode.title ?? "")
                .font(.title2)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
    }
    
    private var play: some View {
        Button(action: onPlayButtonTap) {
            if episode == audioManager.currentEpisode {
                if audioManager.isPlaying {
                    Label("Pause", systemImage: "pause.fill")
                } else {
                    Label("Resume", systemImage: "play.fill")
                }
            } else {
                Label("Play", systemImage: "play.fill")
            }
        }
        .font(.subheadline)
        .controlSize(.large)
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
    }
    
    private var summary: some View {
        Text(episode.summary ?? "")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var details: some View {
        VStack(alignment: .leading) {
            LabeledContent("Format", value: episode.podcast.format.rawValue.localizedCapitalized)
            Divider()
            LabeledContent("Length", value: episode.length.localizedCapitalized)
            Divider()
            LabeledContent("Level", value: episode.level.localizedCapitalized)
        }
        .font(.subheadline)
    }
    
    private func onPlayButtonTap() {
        audioManager.toggle(episode)
    }
}

#Preview(traits: .audioPlayerTrait) {
    NavigationStack {
        EpisodeDetailView(episode: .previewCompleted)
    }
//    EpisodeDetail(episode: .preview)
}
