//
//  PodcastRoot.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import SwiftUI
import SwiftData

struct PodcastRoot: View {
    @State private var showingCreateSheet: Bool = false
    @Environment(PodcastViewModel.self) private var rootModel: PodcastViewModel
    @Environment(AuthManager.self) private var authManager: AuthManager
    @Environment(\.modelContext) private var context: ModelContext

    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        NavigationStack{
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(podcasts) { podcast in
                        NavigationLink(value: podcast) {
                            PodcastCard(podcast: podcast)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .safeAreaPadding(.horizontal)
            .scrollIndicators(.hidden)
            .navigationTitle("Podcasts")
            .navigationDestination(for: Podcast.self) { PodcastDetail(podcast: $0) }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingCreateSheet = true }) {
                        Label("Create", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) { PodcastCreateSheet() }
            .refreshable { await rootModel.refresh(authManager: authManager, context: context) }
            .task { await rootModel.refresh(authManager: authManager, context: context) }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastRoot()
}
