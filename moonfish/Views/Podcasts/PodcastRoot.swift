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
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastRoot()
}
