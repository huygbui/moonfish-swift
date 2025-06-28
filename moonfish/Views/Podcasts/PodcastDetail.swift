//
//  PodcastDetail.swift
//  moonfish
//
//  Created by Huy Bui on 28/6/25.
//

//
//  PodcastDetail.swift
//  moonfish
//
//  Created by Huy Bui on 24/6/25.
//

import SwiftUI
import SwiftData

struct PodcastDetail: View {
    var podcast: Podcast
    @Environment(AudioManager.self) private var audioManager
    @Environment(AuthManager.self) private var authManager
    @Environment(EpisodeViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext

    @State private var showingEpisodeCreate: Bool = false
    @State private var showingPodcastUpdate: Bool = false

    private let imageDimension: CGFloat = 256
    private let playButtonWidth: CGFloat = 128
    private let playButtonHeight: CGFloat = 48
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                cover
                title
                play
                summary
            }
        }
        .safeAreaPadding(.horizontal)
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem {
                Button(action: {showingPodcastUpdate = true}) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEpisodeCreate) { EpisodeCreate() }
        .sheet(isPresented: $showingPodcastUpdate) { PodcastUpdateSheet(podcast: podcast) }
    }
    
    private var cover: some View {
        AsyncImage(url: podcast.imageURL) { image in
            image
                .resizable()
                .aspectRatio(1, contentMode: .fill)
        } placeholder: {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemFill))
                .aspectRatio(1, contentMode: .fit)
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
    
    private var play: some View {
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
    
    private var summary: some View {
        Text(podcast.about ?? "")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastDetail(podcast: .preview)
}
