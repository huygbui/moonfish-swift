//
//  PodcastRoot.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import SwiftUI
import SwiftData

struct PodcastRoot: View {
    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context

    @State private var showCreateSheet = false
    
    private var columns: [GridItem] {
        [.init(.adaptive(minimum: 128, maximum: 512), spacing: 16)]
    }
    
    var body: some View {
        NavigationStack{
            content
                .navigationTitle("Podcasts")
                .navigationDestination(for: Podcast.self, destination: PodcastDetail.init)
                .toolbar { createButton }
                .sheet(isPresented: $showCreateSheet) { PodcastCreateSheet() }
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
            LazyVGrid(columns: columns) {
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
    }
    
    private var podcastEmpty: some View {
        ContentUnavailableView(
            "No Podcasts",
            systemImage: "",
            description: Text("Tap + to create your first podcast")
        )
    }
    
    private var createButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Create", systemImage: "plus") {
                showCreateSheet = true
            }
        }
    }
    
    private func refresh() async {
        await rootModel.refreshPodcasts(authManager: authManager, context: context)
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastRoot()
}
