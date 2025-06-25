//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct PodcastsRoot: View {
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(AudioManager.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext
    
    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]
    
    @State private var showingAccountSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    if !recentPodcasts.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Newly Added").font(.headline)
                            ScrollView(.horizontal) {
                                LazyHStack {
                                    ForEach(recentPodcasts) { podcast in
                                        NavigationLink(value: podcast) {
                                            PodcastCardHighlight(podcast: podcast)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Past Tracks").font(.headline)
                        LazyVStack(spacing: 8) {
                            ForEach(pastPodcasts){ podcast in
                                NavigationLink(value: podcast) {
                                    PodcastCard(podcast: podcast)
                                }
                                .buttonStyle(.plain)
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
            .scrollIndicators(.hidden)
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Podcasts")
            .navigationDestination(for: Podcast.self) { PodcastDetail(podcast: $0)}
            .toolbar {
                ToolbarItem {
                    Button(action: { showingAccountSheet = true }) {
                        Label(
                            "Account",
                            systemImage: "person"
                        )
                    }
                }
            }
            .sheet(isPresented: $showingAccountSheet) { AccountSheet() }
            .task { await rootModel.refresh(context) }
        }
        
        var recentPodcasts: [Podcast] {
            podcasts.filter { $0.isRecent }
        }
        
        var pastPodcasts: [Podcast] {
            podcasts.filter { !$0.isRecent }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastsRoot()
}
