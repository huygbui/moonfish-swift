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
        content
            .environment(AudioPlayer.shared)
            .modelContainer(context)
            .task {
                // Fetch a random podcast from the sample data
                let descriptor = FetchDescriptor<Podcast>()
                
                if let podcast = try? context.mainContext.fetch(descriptor).randomElement() {
                    await MainActor.run {
                        AudioPlayer.shared.currentPodcast = podcast
                        AudioPlayer.shared.duration = Double(podcast.duration)
                        AudioPlayer.shared.isPlaying = true
                        AudioPlayer.shared.currentTime = 45 // Start partway through
                    }
                }
            }
    }
}

// Extension for easy access
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var audioPlayerTrait: Self = .modifier(AudioPlayerPreviewModifier())
}
