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
    
    var body: some View {
        Menu {
            Button("Edit Podcast", systemImage: "slider.horizontal.3", action: onEdit)
            
            Button("Delete Podcast", systemImage: "minus.circle", role: .destructive) {
                Task { await onDelete() }
            }
        } label: {
            Image(systemName: "ellipsis")
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
