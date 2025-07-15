import SwiftUI
import SwiftData

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var audioPlayerTrait: Self = .modifier(AudioPlayerPreviewModifier())
}

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
        let sessionManager = SessionManager()

        return content
            .environment(audioPlayer)
            .environment(episodeRootModel)
            .environment(podcastRootModel)
            .environment(sessionManager)
            .preferredColorScheme(colorSchemePreference.colorScheme)
            .modelContainer(context)
    }
}


