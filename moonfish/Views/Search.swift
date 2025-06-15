//
//  Search.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct Search: View {
    @State private var searchText: String = ""
    @State private var selectedFilter: FilterItem = .all

    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]
    
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
                VStack(spacing: 16) {
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(FilterItem.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading) {
                        ForEach(filteredPodcasts) { podcast in
                            PodcastCard (
                                podcast: podcast
                            )
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .safeAreaPadding(.horizontal, 16)
            .scrollIndicators(.hidden)
            .navigationTitle("All Podcasts")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview(traits: .audioPlayer) {
    Search()
}
