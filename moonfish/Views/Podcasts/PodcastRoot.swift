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
                        VStack {
                            AsyncImage(url: podcast.imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.tertiarySystemFill))
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            Text(podcast.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .safeAreaPadding(.horizontal)
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
