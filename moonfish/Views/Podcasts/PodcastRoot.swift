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

    var body: some View {
        NavigationStack{
            ScrollView {
                LazyVStack {
                    ForEach(podcasts) {
                        Text($0.title)
                    }
                }
                .navigationTitle("Podcasts")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showingCreateSheet = true }) {
                            Label("Create", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingCreateSheet) {
                    PodcastCreateSheet()
                }
            }
            .refreshable {
                await rootModel.refresh(authManager: authManager, context: context)
            }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastRoot()
}
