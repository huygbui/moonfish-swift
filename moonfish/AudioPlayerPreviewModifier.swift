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
        let colorSchemePreference: ColorSchemePreference = .automatic
    
        let audioPlayer = AudioManager() // Use the same instance
        let episodeRootModel = EpisodeViewModel()
        let requestRootModel = RequestViewModel()

        return content
            .environment(audioPlayer)
            .environment(episodeRootModel)
            .environment(requestRootModel)
            .environment(AuthManager())
            .preferredColorScheme(colorSchemePreference.colorScheme)
            .modelContainer(context)
            .task {
                let episode: Episode = .preview
                
                await MainActor.run {
                    audioPlayer.currentEpisode = episode
                    audioPlayer.duration = episode.duration
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
