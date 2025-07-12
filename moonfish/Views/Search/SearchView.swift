//
//  Search.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(EpisodeViewModel.self) private var viewModel
    @Environment(AudioManager.self) private var audioPlayer
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    @State private var apiPodcasts: [EpisodeResponse] = []
    @State private var searchText: String = ""
    @State private var searchStatus: SearchStatusEnum = .completed
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Filter", selection: $searchStatus) {
                    ForEach(SearchStatusEnum.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .controlSize(.large)
                .padding(.horizontal, 16)
                
                EpisodeList(searchText: searchText, searchStatus: searchStatus)
                    .navigationTitle("All Podcasts")
                    .navigationBarTitleDisplayMode(.inline)
                    .searchable(text: $searchText)
            }
        }
    }
}

struct EpisodeList: View {
    @Query private var episodes: [Episode]

    init(searchText: String, searchStatus: SearchStatusEnum) {
        let statusString = searchStatus.statusString
        let sortDescriptor = SortDescriptor(\Episode.createdAt, order: .reverse)
        
        let predicate: Predicate<Episode>
        if searchText.isEmpty {
            predicate = #Predicate<Episode> {
                $0.status == statusString
            }
        } else {
            predicate = #Predicate<Episode> {
                $0.status == statusString &&
                $0.title?.localizedStandardContains(searchText) == true
            }
        }
        
        _episodes = Query(filter: predicate, sort: [sortDescriptor])
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(episodes.indices, id: \.self) { index in
                    EpisodeCard(episode: episodes[index])
                    if index < episodes.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .safeAreaPadding(.horizontal, 16)
        .scrollIndicators(.hidden)
        .conditionalSafeAreaBottomPadding()
    }
}
    
enum SearchStatusEnum: String, Identifiable, CaseIterable {
    case completed = "Completed"
    case running = "Running"
    case failed = "Failed"
    
    var id: Self { self }
    
    var statusString: String {
        switch self {
        case .completed:
            "completed"
        case .running:
            "active"
        case .failed:
            "failed"
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    SearchView()
}
