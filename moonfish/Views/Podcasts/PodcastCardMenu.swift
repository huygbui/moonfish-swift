//
//  CardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCardMenu: View {
    var viewModel: PodcastViewModel
    var podcast: Podcast
    
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.backendClient) private var client: BackendClient
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    
    var body: some View {
        Menu {
            Button(action: viewModel.toggleFavorite) {
                Label(
                    podcast.isFavorite ? "Remove Favorite" : "Add to Favorites",
                    systemImage: podcast.isFavorite ? "heart.fill" : "heart"
                )
            }
            
            Button(action: viewModel.downloadPodcast) {
                Label(
                    podcast.isDownloaded ? "Remove Download" : "Download Episode",
                    systemImage: podcast.isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle"
                )
            }
            
            Button(role: .destructive, action: { showingAlert = true } ) {
                Label(
                    "Delete Episode",
                    systemImage: "trash"
                )
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
                .frame(width: 24, height: 24)
                .background(Color(.tertiarySystemBackground), in: .circle)
        }
        .alert("Delete Episode", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel
                        .deletePodcast(
                            audioPlayer: audioPlayer,
                            client: client,
                            modelContext: context
                        )
                }
                dismiss()
            }
        } message: {
            Text("This episode will be deleted forever.")
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    let podcast: Podcast = .preview
    let viewModel = PodcastViewModel(podcast: podcast)
    
    PodcastCardMenu(viewModel: viewModel, podcast: podcast)
}
