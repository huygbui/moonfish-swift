//
//  PodcastDetail.swift
//  moonfish
//
//  Created by Huy Bui on 28/6/25.
//

import SwiftUI
import SwiftData

struct PodcastDetailView: View {
    let podcast: Podcast
    @Environment(AudioManager.self) private var audioManager
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEpisodeCreate: Bool = false
    @State private var showingPodcastUpdate: Bool = false
    
    @Query private var episodes: [Episode]
    
    init(podcast: Podcast) {
        self.podcast = podcast
        
        let podcastID = podcast.persistentModelID
        _episodes = Query(
            filter: #Predicate<Episode> {
                $0.podcast.persistentModelID == podcastID &&
                $0.status != "failed" &&
                $0.status != "cancelled"
            },
            sort: \Episode.createdAt,
            order: .reverse
        )
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
        .conditionalSafeAreaBottomPadding()
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
        LazyVStack(spacing: 8) {
            ForEach(episodes) { episode in
                if episode.status == EpisodeStatus.completed.rawValue {
                    NavigationLink(destination: EpisodeDetailView(episode: episode)) {
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
                        await rootModel.delete(podcast, context: context)
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func refresh() async {
        await rootModel.refreshEpisodes(for: podcast, context: context)
    }
}

#Preview(traits: .audioPlayerTrait) {
    NavigationStack {
        PodcastDetailView(podcast: .preview)
    }
}
