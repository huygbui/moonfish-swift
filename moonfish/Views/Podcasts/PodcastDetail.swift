//
//  PodcastDetail.swift
//  moonfish
//
//  Created by Huy Bui on 28/6/25.
//

import SwiftUI
import SwiftData

struct PodcastDetail: View {
    let podcast: Podcast
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEpisodeCreate: Bool = false
    @State private var showingPodcastUpdate: Bool = false
    
    private var episodes: [Episode] {
        podcast.episodes
            .filter { $0.status != EpisodeStatus.failed.rawValue && $0.status != EpisodeStatus.cancelled.rawValue }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        content
            .toolbar { menuButton }
            .sheet(isPresented: $showingEpisodeCreate) { EpisodeCreateSheet(podcast: podcast) }
            .sheet(isPresented: $showingPodcastUpdate) { PodcastUpdateSheet(podcast: podcast) }
            .refreshable { await refresh() }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                cover
                title
                addButton
                episodeList
            }
        }
        .safeAreaPadding(.horizontal)
        .scrollIndicators(.hidden)
    }
    
    private var cover: some View {
        PodcastAsyncImage(url: podcast.imageURL)
            .frame(width: 160, height: 160)
            .cornerRadius(16)
    }
    
    private var title: some View {
        Text(podcast.title)
            .font(.title2)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
    }
    
    private var addButton: some View {
        Button("Add Episode", systemImage: "plus") {
           showingEpisodeCreate = true
        }
            .font(.subheadline)
            .controlSize(.large)
            .buttonStyle(.bordered)
            .foregroundStyle(.primary)
    }

    private var episodeList: some View {
        VStack(spacing: 8) {
            ForEach(episodes) { episode in
                if episode.status == EpisodeStatus.completed.rawValue {
                    NavigationLink(destination: EpisodeDetail(episode: episode)) {
                        EpisodeRow(episode: episode)
                    }
                    .buttonStyle(.plain)
                } else {
                    EpisodeRow(episode: episode)
                }
                
               
                Divider()
            }
        }
        .padding(.top, 16)
    }
    
    private var menuButton: some ToolbarContent {
        ToolbarItem {
            PodcastMenu(
                onEdit: { showingPodcastUpdate = true },
                onDelete: {
                    Task {
                        await rootModel.delete(podcast, authManager: authManager, context: context)
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func refresh() async {
        await rootModel.refreshEpisodes(for: podcast, authManager: authManager, context: context)
    }
}

#Preview(traits: .audioPlayerTrait) {
    NavigationStack {
        ZStack {
//            Color(.secondarySystemBackground)
//                .ignoresSafeArea()
            PodcastDetail(podcast: .preview)
        }
    }
}
