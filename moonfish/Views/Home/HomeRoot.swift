//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct HomeRoot: View {
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(PodcastViewModel.self) private var podcastViewModel
    @Environment(AudioManager.self) private var audioPlayer
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context: ModelContext
    
    @Query(Episode.recentDescriptor) private var recentEpisodes: [Episode]
    @Query(Episode.pastDescriptor) private var pastEpisodes: [Episode]
    @Query private var podcasts: [Podcast]
    
    @State private var showingSettingsSheet: Bool = false
    @State private var showingCreateSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Home")
                .navigationDestination(for: Episode.self, destination: EpisodeDetail.init)
                .navigationDestination(for: Podcast.self, destination: PodcastDetail.init)
                .toolbar {
                    SettingToolbarItem { showingSettingsSheet = true }
                    if #available(iOS 26.0, *) { ToolbarSpacer() }
                    CreateToolbarItem { showingCreateSheet = true }
                }
                .sheet(isPresented: $showingSettingsSheet) { SettingsSheet() }
                .sheet(isPresented: $showingCreateSheet) { PodcastCreateSheet() }
                .refreshable {
                    await podcastViewModel.refreshPodcasts(authManager: authManager, context: context)
                    await podcastViewModel.refreshEpisodes(authManager: authManager, context: context)
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if !podcasts.isEmpty {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    episodeHighlight
                    podcastHighlight
                    episodePast
                }
                .padding(.bottom, {
                    if #available(iOS 26.0, *) {
                        return 0
                    } else {
                        return 128
                    }
                }())
            }
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .scrollIndicators(.hidden)
        } else {
            ContentUnavailableView(
                "No Podcasts",
                systemImage: "",
                description: Text("Go to \"Podcasts\" to create your first")
            )
        }
    }
   
    @ViewBuilder
    private var episodeHighlight: some View {
        if !recentEpisodes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Newly Added").font(.headline)
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        ForEach(recentEpisodes) { episode in
                            NavigationLink(value: episode) {
                                EpisodeHighlight(episode: episode)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    @ViewBuilder
    private var podcastHighlight: some View {
        if !podcasts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Favorite Shows").font(.headline)
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        ForEach(podcasts) { podcast in
                            NavigationLink(value: podcast) {
                                PodcastHighlight(podcast: podcast)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
   
    @ViewBuilder
    private var episodePast: some View {
        if !pastEpisodes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Listen Again").font(.headline)
                LazyVStack(spacing: 16) {
                    ForEach(pastEpisodes){ episode in
                        NavigationLink(value: episode) {
                            EpisodeCard(episode: episode)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    HomeRoot()
}
