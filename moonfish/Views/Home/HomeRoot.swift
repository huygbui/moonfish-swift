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
    @Environment(AudioManager.self) private var audioPlayer
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context: ModelContext
    
    @Query(sort: \Episode.createdAt, order: .reverse) private var episodes: [Episode]
    
    @State private var showingSettingsSheet: Bool = false
    @State private var showingCreateSheet: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    if !recentEpisodes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Newly Added").font(.headline)
                            ScrollView(.horizontal) {
                                LazyHStack {
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Past Episodes").font(.headline)
                        LazyVStack(spacing: 8) {
                            ForEach(pastEpisodes){ episode in
                                NavigationLink(value: episode) {
                                    EpisodeCard(episode: episode)
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
            .navigationTitle("Home")
            .navigationDestination(for: Episode.self) { EpisodeDetail(episode: $0)}
            .toolbar {
                ToolbarItem {
                    Button(action: { showingSettingsSheet = true }) {
                        Label("Setting", systemImage: "person")
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) { SettingsSheet() }
            .sheet(isPresented: $showingCreateSheet) { PodcastCreateSheet() }
            .task { await rootModel.refresh(context, authManager: authManager) }
        }
        
        var recentEpisodes: [Episode] {
            episodes.filter { $0.isRecent }
        }
        
        var pastEpisodes: [Episode] {
            episodes.filter { !$0.isRecent }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    HomeRoot()
}
