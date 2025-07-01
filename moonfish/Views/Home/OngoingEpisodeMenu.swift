//
//  OngoingEpisodeMenu.swift
//  moonfish
//
//  Created by Huy Bui on 1/7/25.
//

import SwiftUI
import SwiftData


struct OngoingEpisodeMenu: View {
    let episode: Episode
   
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCancelConfirmation: Bool = false
    
    var body: some View {
        Menu {
            Button(role: .destructive, action: onCancelButtonTap) {
                Label(
                    "Cancel Episode",
                    systemImage: "trash"
                )}
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
        }
        .confirmationDialog(
            "Cancel Episode",
            isPresented: $showCancelConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { onConfirmedCancelButtonTap() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This episode will be canceled.")
        }
    }
    
    private func onCancelButtonTap() {
        showCancelConfirmation = true
    }
    
    private func onConfirmedCancelButtonTap() {
        Task {
            await rootModel.cancel(episode, authManager: authManager, context: context)
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    OngoingEpisodeMenu(episode: .preview)
}
