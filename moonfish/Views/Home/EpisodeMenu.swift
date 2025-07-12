//
//  CardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeMenu: View {
    let episode: Episode
   
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Menu {
            Button(action: onFavoriteButtonTap) {
                Label(
                    episode.isFavorite ? "Remove Favorite" : "Add to Favorites",
                    systemImage: episode.isFavorite ? "heart.fill" : "heart"
                )}
            
            Button(action: onDownloadButtonTap) {
                Label(
                    episode.isDownloaded ? "Remove Download" : "Download Episode",
                    systemImage: episode.isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle"
                )}
            
            Button(role: .destructive, action: onDeleteButtonTap) {
                Label(
                    "Delete Episode",
                    systemImage: "trash"
                )}
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
        }
        .confirmationDialog(
            "Delete Episode",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { onConfirmedDeleteButtonTap() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This episode will be deleted permanently.")
        }
    }

    private func onDeleteButtonTap() {
        showDeleteConfirmation = true
    }

    private func onFavoriteButtonTap() {
        rootModel.toggleFavorite(episode)
    }
    
    private func onDownloadButtonTap() {
        if episode.isDownloaded {
            rootModel.removeDownload(for: episode)
        } else {
            Task { try? await rootModel.download(episode, authManager: authManager) }
        }
    }
    
    private func onConfirmedDeleteButtonTap() {
        Task {
            await rootModel.delete(episode, context: context, authManager: authManager)
            audioManager.handleDeletion(of: episode)
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    EpisodeMenu(episode: .preview)
}
