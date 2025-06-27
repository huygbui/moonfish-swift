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
    @Environment(PodcastViewModel.self) private var rootModel
    @Environment(\.modelContext) private var context: ModelContext

    @State private var isExpanded = false
    
    private let imageDimension: CGFloat = 256
    private let playButtonWidth: CGFloat = 128
    private let playButtonHeight: CGFloat = 48
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                cover
                title
                play
                summary
                details
            }
            .toolbar {
                ToolbarItem { PodcastCardMenu(podcast: podcast) }
            }
        }
        .safeAreaPadding(.horizontal)
        .scrollIndicators(.hidden)
    }
    
    private var cover: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.tertiary)
            .frame(width: imageDimension, height: imageDimension)
    }
    
    private var title: some View {
        VStack(spacing: 0) {
            Text("\(podcast.createdAt.compact) • \(podcast.duration.hoursMinutes)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(podcast.title)
                .font(.title)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
    }
    
    private var play: some View {
        Button {
            Task {
                await rootModel.refreshAudioURL(
                    podcast,
                    modelContext: context,
                    authManager: authManager
                )
                audioManager.toggle(podcast)
            }
        } label: {
            Image(systemName: audioManager.isPlaying(podcast)
                  ? "pause.fill" : "play.fill"
            )
                .frame(width: playButtonWidth, height: playButtonHeight)
                .background(.primary, in: .capsule.stroke(lineWidth: 1))
        }
        .controlSize(.large)
        .buttonStyle(.plain)
    }
    
    private var summary: some View {
        Text(podcast.summary)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var details: some View {
        VStack(alignment: .leading) {
            LabeledContent("Format", value: podcast.format.localizedCapitalized)
            Divider()
            LabeledContent("Length", value: podcast.length.localizedCapitalized)
            Divider()
            LabeledContent("Level", value: podcast.level.localizedCapitalized)
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastDetail(podcast: .preview)
}
