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
        let podcastRootModel = PodcastViewModel()
        let subscriptionManager = SubscriptionManager()
        let authManager = AuthManager()

        return content
            .environment(audioPlayer)
            .environment(episodeRootModel)
            .environment(podcastRootModel)
            .environment(authManager)
            .environment(subscriptionManager)
            .preferredColorScheme(colorSchemePreference.colorScheme)
            .modelContainer(context)
            .task {
                let episode: Episode = .previewCompleted
                
                await MainActor.run {
                    audioPlayer.play(episode)
                }
            }
            .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
                if newValue {
                    // User just signed in
                    Task {
                        await subscriptionManager.setAuthManager(authManager)
                    }
                } else {
                    // User just signed out
                    Task {
                        await subscriptionManager.clearAuth()
                    }
                }
            }
    }
}

// Extension for easy access
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var audioPlayerTrait: Self = .modifier(AudioPlayerPreviewModifier())
}
