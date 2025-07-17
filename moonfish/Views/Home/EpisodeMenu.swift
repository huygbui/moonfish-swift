//
//  EpisodeMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct EpisodeMenu: View {
    let episode: Episode
    
    @Environment(AudioManager.self) private var audioManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext
    
    @State private var showDeleteConfirmation = false
    @State private var showCancelConfirmation = false
    
    var body: some View {
        Menu {
            menuActions
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
        }
        .confirmationDialog("Delete Episode", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive, action: deleteEpisode)
        } message: {
            Text("This episode will be deleted permanently.")
        }
        .confirmationDialog("Cancel Episode", isPresented: $showCancelConfirmation) {
            Button("Cancel Episode", role: .destructive, action: cancelEpisode)
        } message: {
            Text("This episode will be canceled.")
        }
    }
    
    // MARK: - Menu Actions
    
    @ViewBuilder
    private var menuActions: some View {
        switch episode.status {
        case "completed":
            completedEpisodeActions
        case "active":
            activeEpisodeActions
        case "failed":
            failedEpisodeActions
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var completedEpisodeActions: some View {
        Button(action: toggleFavorite) {
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
        
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("Delete Episode", systemImage: "trash")
        }
    }
    
    @ViewBuilder
    private var activeEpisodeActions: some View {
        Button(role: .destructive) {
            showCancelConfirmation = true
        } label: {
            Label("Cancel Episode", systemImage: "trash")
        }
    }
    
    @ViewBuilder
    private var failedEpisodeActions: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("Delete Episode", systemImage: "trash")
        }
    }
    
    // MARK: - Actions
    
    private func toggleFavorite() {
        rootModel.toggleFavorite(episode)
    }
    
    private func toggleDownload() {
        if episode.isDownloaded {
            rootModel.removeDownload(for: episode)
        } else {
            Task {
                try? await rootModel.download(episode)
            }
        }
    }
    
    private func deleteEpisode() {
        Task {
            await rootModel.delete(episode, context: context)
            audioManager.handleDeletion(of: episode)
        }
    }
    
    private func cancelEpisode() {
        Task {
            await rootModel.cancel(episode, context: context)
        }
    }
}

// MARK: - Previews

#Preview("Completed Episode", traits: .audioPlayerTrait) {
    EpisodeMenu(episode: .previewCompleted)
}

#Preview("Active Episode", traits: .audioPlayerTrait) {
    EpisodeMenu(episode: .previewActive)
}

#Preview("Failed Episode", traits: .audioPlayerTrait) {
    EpisodeMenu(episode: .previewFailed)
}
