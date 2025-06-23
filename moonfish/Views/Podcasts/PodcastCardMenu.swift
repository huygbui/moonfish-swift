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
    
    @Environment(AudioController.self) private var audioPlayer
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    
    var body: some View {
        Menu {
            Button(action: { rootModel.toggleFavorite(podcast) }) {
                Label(
                    podcast.isFavorite ? "Remove Favorite" : "Add to Favorites",
                    systemImage: podcast.isFavorite ? "heart.fill" : "heart"
                )
            }
            
            Button(action: toggleDownload) {
                Label(
                    downloadButtonText,
                    systemImage: downloadButtonImageName
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
    
    func toggleDownload() {
        switch podcast.downloadState {
        case .idle, .canceled:
            Task { try? await rootModel.download(podcast) }
        case .dowloading:
            rootModel.cancelDownload(for: podcast)
        case .completed:
            rootModel.removeDownload(for: podcast)
        }
    }
    
    var downloadButtonImageName: String {
        switch podcast.downloadState {
        case .dowloading: return "pause.fill"
        case .completed: return "arrow.down.circle.fill"
        case .idle, .canceled: return "arrow.down.circle"
        }
    }
    
    var downloadButtonText: String {
        switch podcast.downloadState {
        case .dowloading: return "Stop Download"
        case .completed: return "Remove Download"
        case .idle, .canceled: return "Download Episode"
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastCardMenu(podcast: .preview)
}
