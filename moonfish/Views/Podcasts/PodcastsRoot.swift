//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct PodcastsRoot: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.backendClient) private var client: BackendClient
    @Environment(AudioPlayer.self) private var audioPlayer
    
    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]
    
    @State private var apiPodcasts: [CompletedPodcastResponse] = []
    @State private var isPresented: Bool = false
    
    var body: some View {
        // Calculate date 3 days ago
        let threeDaysInSeconds: TimeInterval = 3 * 24 * 60 * 60
        let recents = podcasts.filter { $0.createdAt.timeIntervalSinceNow > -threeDaysInSeconds }
        let pasts = podcasts.filter { $0.createdAt.timeIntervalSinceNow <= -threeDaysInSeconds }
        
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    if !recents.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Newly Added").font(.headline)
                            ScrollView(.horizontal) {
                                LazyHStack {
                                    ForEach(recents) { podcast in
                                        let viewModel = PodcastViewModel(podcast: podcast)
                                        PodcastCardHighlight(viewModel: viewModel)
                                            .frame(width: 256, height: 256)
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Past Tracks").font(.headline)
                        LazyVStack(spacing: 8) {
                            ForEach(pasts){ podcast  in
                                let viewModel = PodcastViewModel(podcast: podcast)
                                PodcastCard(viewModel: viewModel, podcast: podcast)
                            }
                        }
                    }
                    .padding(.bottom, {
                        if #available(iOS 26.0, *) {
                            return 0
                        } else {
                            return 128
                        }
                    }())
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



#Preview(traits: .audioPlayerTrait) {
    PodcastsRoot()
}
