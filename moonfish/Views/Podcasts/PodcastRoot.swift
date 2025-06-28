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
                    ForEach(podcasts) { podcast in
                        HStack {
                            AsyncImage(url: podcast.imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color(.tertiarySystemFill)
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            Text(podcast.title)
                                .font(.headline)
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                .scrollIndicators(.hidden)
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
            .task {
                await rootModel.refresh(authManager: authManager, context: context)
            }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastRoot()
}
