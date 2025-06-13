//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct Podcasts: View {
    var audioPlayer: AudioPlayer
    @State private var isPresented: Bool = false
    @Query(sort: \Podcast.createdAt, order: .reverse) private var podcasts: [Podcast]

    var body: some View {
        let topThrees = Array(podcasts.prefix(3))
        let remainings = Array(podcasts.dropFirst(3))
        
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Newly Added").font(.headline)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(topThrees) {
                                    PodcastCardHighlight(
                                        podcast: $0,
                                        audioPlayer: audioPlayer
                                    )
                                    .frame(width: 256, height: 256)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Past Tracks").font(.headline)
                        VStack(spacing: 8) {
                            ForEach(remainings){
                                PodcastCard(
                                    podcast: $0,
                                    audioPlayer: audioPlayer
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Podcasts")
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .toolbar {
                ToolbarItem {
                    Button(action: {  }) {
                        Image(systemName: "person")
                    }
                }
            }
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    Podcasts(audioPlayer: AudioPlayer())
        .modelContainer(SampleData.shared.modelContainer)
}
