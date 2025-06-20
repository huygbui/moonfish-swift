//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct PodcastsRoot: View {
    @Environment(PodcastViewModel.self) private var viewModel
    @Environment(AudioPlayer.self) private var audioPlayer
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
                                    ForEach(recentPodcasts) {
                                        PodcastCardHighlight(podcast: $0)
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
                            ForEach(pastPodcasts){
                                PodcastCard(podcast: $0)
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
                    Button(action: { showingAccountSheet = true }) {
                        Label(
                            "Account",
                            systemImage: "person"
                        )
                    }
                }
            }
            .sheet(isPresented: $showingAccountSheet) { AccountSheet() }
            .task { await viewModel.refresh(context) }
        }
        
        var recentPodcasts: [Podcast] {
            podcasts.filter { $0.createdAt.timeIntervalSinceNow > -3 * 24 * 60 * 60 }
        }
        
        var pastPodcasts: [Podcast] {
            podcasts.filter { $0.createdAt.timeIntervalSinceNow <= -3 * 24 * 60 * 60 }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastsRoot()
}
