//
//  PodcastDetail.swift
//  moonfish
//
//  Created by Huy Bui on 28/6/25.
//

import SwiftUI
import SwiftData

struct PodcastDetail: View {
    let podcast: Podcast
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEpisodeCreate: Bool = false
    @State private var showingPodcastUpdate: Bool = false

    private let imageDimension: CGFloat = 160
    private let playButtonWidth: CGFloat = 128
    private let playButtonHeight: CGFloat = 48
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                cover
                title
                addButton
                about
                episodeList
            }
        }
        .safeAreaPadding(.horizontal)
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem {
                PodcastMenu(
                    onEdit: { showingPodcastUpdate = true },
                    onDelete: {
                        await rootModel.delete(podcast, authManager: authManager, context: context)
                        dismiss()
                    }
                )
            }
        }
        .sheet(isPresented: $showingEpisodeCreate) { EpisodeCreateSheet(podcast: podcast) }
        .sheet(isPresented: $showingPodcastUpdate) { PodcastUpdateSheet(podcast: podcast) }
        .refreshable {
            await rootModel.refreshEpisodes(for: podcast, authManager: authManager, context: context)
        }
    }
    
    private var cover: some View {
        AsyncImage(url: podcast.imageURL) { image in
            image
                .resizable()
                .aspectRatio(1, contentMode: .fill)
        } placeholder: {
            Color(.tertiarySystemFill)
        }
        .frame(width: imageDimension, height: imageDimension)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var title: some View {
        Text(podcast.title)
            .font(.title)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
    }
    
    private var addButton: some View {
        Button {
           showingEpisodeCreate = true
        } label: {
            Image(systemName: "plus")
                .frame(width: playButtonWidth, height: playButtonHeight)
                .background(.primary, in: .capsule.stroke(lineWidth: 1))
        }
        .controlSize(.large)
        .buttonStyle(.plain)
    }
    
    private var about: some View {
        podcast.about.map {
            Text($0)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
    }

    private var episodeList: some View {
        LazyVStack(spacing: 8) {
            ForEach(podcast.episodes) { episode in
                Group {
                    NavigationLink(destination: EpisodeDetail(episode: episode)) {
                        EpisodeRow(episode: episode)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                }
            }
        }
        .padding(.top, 16)
    }
}

#Preview(traits: .audioPlayerTrait) {
    NavigationStack {
        ZStack {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
            PodcastDetail(podcast: .preview)
        }
    }
}
