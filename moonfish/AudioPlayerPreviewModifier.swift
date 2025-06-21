//
//  AudioPlayerPreviewModifier.swift
//  moonfish
//
//  Created by Huy Bui on 15/6/25.
//

import SwiftUI
import SwiftData

struct AudioPlayerPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        // Return the shared sample data container
        return SampleData.shared.modelContainer
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        let audioPlayer = AudioPlayer() // Use the same instance
        let podcastRootModel = PodcastViewModel()
        let requestRootModel = RequestViewModel()

        return content
            .environment(audioPlayer)
            .environment(podcastRootModel)
            .environment(requestRootModel)
            .modelContainer(context)
            .task {
                let podcast: Podcast = .preview
                
                await MainActor.run {
                    audioPlayer.currentPodcast = podcast
                    audioPlayer.duration = podcast.duration
                    audioPlayer.isPlaying = true
                    audioPlayer.currentTime = 45 // Start partway through
                }
            }
    }
}

// Extension for easy access
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var audioPlayerTrait: Self = .modifier(AudioPlayerPreviewModifier())
}
