//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct Podcasts: View {
    @State private var isPresented: Bool = false
    @Environment(AudioPlayer.self) private var audioPlayer
    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]

    var body: some View {
        let topThrees = Array(podcasts.prefix(3))
        let remainings = Array(podcasts.dropFirst(3))
        
        
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Newly Added").font(.headline)
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(topThrees) {
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
                            ForEach(remainings){
                                PodcastCard(
                                    podcast: $0,
                                )
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
            .sheet(isPresented: $isPresented) {
                AccountSheet()
            }
            .task {
                await refresh()
            }
        }
    }
}

func refresh() async {
    do {
        
    } catch {
        
    }
}

#Preview(traits: .audioPlayer) {
    Podcasts()
}
