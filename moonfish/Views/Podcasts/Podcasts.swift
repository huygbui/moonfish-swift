//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct Podcasts: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.backendClient) private var client: BackendClient
    @Environment(AudioPlayer.self) private var audioPlayer
    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]
    @State private var apiPodcasts: [CompletedPodcastResponse] = []
    @State private var isPresented: Bool = false
    
    var body: some View {
        // Calculate date 3 days ago
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let recents = podcasts.filter { $0.createdAt >= threeDaysAgo }
        let pasts = podcasts.filter { $0.createdAt < threeDaysAgo }
        
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Newly Added").font(.headline)
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(recents) {
                                    PodcastCardHighlight(
                                        podcast: $0,
                                    )
                                    .frame(width: 256, height: 256)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Past Tracks").font(.headline)
                        LazyVStack(spacing: 8) {
                            ForEach(pasts){
                                PodcastCard(podcast: $0)
                            }
                        }
                    }
                }
            }
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Podcasts")
            .toolbar {
                ToolbarItem {
                    Button(action: { isPresented = true }) {
                        Image(systemName: "person")
                    }
                }
            }
            .sheet(isPresented: $isPresented) { AccountSheet() }
            .task { await refresh() }
        }
    }
    
    func refresh() async {
        do {
            apiPodcasts = try await client.getCompletedPodcasts()
            for apiPodcast in apiPodcasts {
                if let podcast = Podcast(from: apiPodcast) {
                    modelContext.insert(podcast)
                }
            }
            try modelContext.save()
        } catch {
            print("Failed to fetch podcasts: \(error)")
        }
    }
}



#Preview(traits: .audioPlayer) {
    Podcasts()
}
