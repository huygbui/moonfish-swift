//
//  CardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeMenu: View {
    var episode: Episode
    
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Menu {
            Button(action: { rootModel.toggleFavorite(episode) }) {
                Label(
                    episode.isFavorite ? "Remove Favorite" : "Add to Favorites",
                    systemImage: episode.isFavorite ? "heart.fill" : "heart"
                )
            }
            
            Button(action: toggleDownload) {
                Label(
                    episode.isDownloaded ? "Remove Download" : "Download Episode",
                    systemImage: episode.isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle"
                )
            }
            
            Button("Delete Episode", systemImage: "trash", role: .destructive) {
                showingDeleteConfirmation = true
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
        }
        .confirmationDialog(
            "Delete Episode",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await rootModel.delete(episode, context: context, authManager: authManager)
                    audioManager.handleDeletion(of: episode)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This episode will be deleted permanently.")
        }
    }
    
    func toggleDownload() {
        if episode.isDownloaded {
            rootModel.removeDownload(for: episode)
        } else {
            Task { try? await rootModel.download(episode, authManager: authManager) }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    EpisodeMenu(episode: .preview)
}
