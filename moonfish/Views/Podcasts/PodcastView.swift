//
//  PodcastRoot.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import SwiftUI
import SwiftData

struct PodcastView: View {
    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context

    @State private var showingSettingSheet = false
    @State private var showingCreateSheet = false

    private var columns: [GridItem] {
        [.init(.adaptive(minimum: 128, maximum: 512), spacing: 16)]
    }
    
    var body: some View {
        NavigationStack{
            content
                .navigationTitle("Podcasts")
                .navigationDestination(for: Podcast.self, destination: PodcastDetailView.init)
                .toolbar {
                    SettingToolbarItem { showingSettingSheet = true }
                    if #available(iOS 26.0, *) { ToolbarSpacer() }
                    CreateToolbarItem { showingCreateSheet = true }
                }
                .sheet(isPresented: $showingCreateSheet) { PodcastCreateSheet() }
                .sheet(isPresented: $showingSettingSheet) { SettingsSheet() }
                .refreshable { await refresh() }
        }
    }
   
    @ViewBuilder
    private var content: some View {
        if podcasts.isEmpty {
            podcastEmpty
        } else {
            podcastGrid
        }
    }
    
    private var podcastGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(podcasts) { podcast in
                    NavigationLink(value: podcast) {
                        PodcastCard(podcast: podcast)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .safeAreaPadding(.horizontal)
        .scrollIndicators(.hidden)
        .conditionalSafeAreaBottomPadding()
    }
    
    private var podcastEmpty: some View {
        ContentUnavailableView(
            "No Podcasts",
            systemImage: "",
            description: Text("Tap + to create your first podcast")
        )
    }
    
    private func refresh() async {
        await rootModel.refreshPodcasts(authManager: authManager, context: context)
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastView()
}
