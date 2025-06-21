//
//  CardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PodcastCardMenu: View {
    var podcast: Podcast
    
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    
    var body: some View {
        Menu {
            Button(action: {}) {
                Label(
                    podcast.isFavorite ? "Remove Favorite" : "Add to Favorites",
                    systemImage: podcast.isFavorite ? "heart.fill" : "heart"
                )
            }
            
            Button(action: {}) {
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
        }
        .alert("Delete Episode", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await rootModel.delete(podcast, context: context)
                    if podcast == audioPlayer.currentPodcast {
                        audioPlayer.pause()
                        audioPlayer.currentPodcast = nil
                    }
                    dismiss()
                }
            }
        } message: {
            Text("This episode will be deleted forever.")
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastCardMenu(podcast: .preview)
}
