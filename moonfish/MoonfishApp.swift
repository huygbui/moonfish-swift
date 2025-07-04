//
//  moonfishApp.swift
//  moonfish
//
//  Created by Huy Bui on 11/2/25.
//

import SwiftUI
import SwiftData

@main
struct MoonfishApp: App {
    @AppStorage("colorSchemePreference") var colorSchemePreference: ColorSchemePreference = .automatic
    
    @State private var audioManager = AudioManager()
    @State private var authManager = AuthManager()
    @State private var epísodeRootModel = EpisodeViewModel()
    @State private var podcastRootModel = PodcastViewModel()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                Root()
                    .modelContainer(for: Podcast.self)
                    .environment(audioManager)
                    .environment(authManager)
                    .environment(epísodeRootModel)
                    .environment(podcastRootModel)
                    .preferredColorScheme(colorSchemePreference.colorScheme)
            } else {
                SignInView()
                    .environment(authManager)
                    .preferredColorScheme(colorSchemePreference.colorScheme)
            }
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
