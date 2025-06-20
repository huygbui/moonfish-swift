//
//  Search.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct SearchRoot: View {
    @Environment(PodcastViewModel.self) private var viewModel
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]
    
    @State private var apiPodcasts: [CompletedPodcastResponse] = []
    @State private var searchText: String = ""
    @State private var selectedFilter: FilterItem = .all
    
    var filteredPodcasts: [Podcast] {
        var filtered = podcasts
        
        // Apply tab filter
        switch selectedFilter {
        case .all:
            filtered = podcasts
        case .downloaded:
            filtered = podcasts.filter { $0.isDownloaded }
        case .favorite:
            filtered = podcasts.filter { $0.isFavorite }
        }
        
        // Apply search filter if search text is not empty
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(FilterItem.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.large)
                    
                    LazyVStack(alignment: .leading) {
                        ForEach(filteredPodcasts) { podcast in
                            PodcastCard(podcast: podcast)
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
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
            .safeAreaPadding(.horizontal, 16)
            .navigationTitle("All Podcasts")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .searchable(text: $searchText)
            .refreshable { await refresh() }
            .task { await refresh() }
        }
    }
    
    func refresh() async {
//        do {
//            apiPodcasts = try await client.getCompletedPodcasts()
//            for apiPodcast in apiPodcasts {
//                if let podcast = Podcast(from: apiPodcast) {
//                    modelContext.insert(podcast)
//                }
//            }
//            try modelContext.save()
//        } catch {
//            print("Failed to fetch podcasts: \(error)")
//        }
    }
}
    
enum FilterItem: String, Identifiable, CaseIterable {
    case all = "All"
    case favorite = "Favorite"
    case downloaded = "Downloaded"

    var id: Self { self }
}

#Preview(traits: .audioPlayerTrait) {
    SearchRoot()
}
