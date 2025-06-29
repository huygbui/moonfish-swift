//
//  PodcastMenu.swift
//  moonfish
//
//  Created by Huy Bui on 29/6/25.
//

import SwiftUI

struct PodcastMenu: View {
    let onEdit: () -> Void
    let onDelete: () async -> Void
    @State private var showingDeleteConfirmation: Bool = false
    
    var body: some View {
        Menu {
            Button("Edit Podcast", systemImage: "slider.horizontal.3", action: onEdit)
            
            Button("Delete Podcast", systemImage: "minus.circle", role: .destructive) {
                showingDeleteConfirmation = true
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .confirmationDialog(
            "Delete Podcast",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task { await onDelete() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This podcast and all its episodes will be deleted permanently.")
        }
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground)
        PodcastMenu(onEdit: {}, onDelete: {})
    }
    .ignoresSafeArea()
}
