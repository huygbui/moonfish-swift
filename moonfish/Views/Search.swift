//
//  Search.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct Search: View {
    var audioPlayer: AudioPlayer
    @State private var searchText: String = ""
    @State private var selectedOrder: Int = 0

    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]
    
    var filteredPodcasts: [Podcast] {
        if searchText.isEmpty {
            return podcasts
        } else {
            return podcasts.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(filteredPodcasts) { podcast in
                        PodcastCard (
                            podcast: podcast,
                            audioPlayer: audioPlayer
                        )
                    }
                }
            }
            .searchable(text: $searchText)
            .safeAreaPadding(.horizontal, 16)
            .navigationTitle("All Podcasts")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    Search(audioPlayer: AudioPlayer())
        .modelContainer(SampleData.shared.modelContainer)
}
