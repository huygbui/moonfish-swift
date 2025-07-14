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
    @State private var sessionManager = SessionManager()
    @State private var epísodeRootModel = EpisodeViewModel()
    @State private var podcastRootModel = PodcastViewModel()

    var body: some Scene {
        WindowGroup {
            if sessionManager.isAuthenticated {
                RootView()
                    .modelContainer(for: Podcast.self)
                    .environment(audioManager)
                    .environment(sessionManager)
                    .environment(epísodeRootModel)
                    .environment(podcastRootModel)
                    .preferredColorScheme(colorSchemePreference.colorScheme)
            } else {
                SignInView()
                    .environment(sessionManager)
                    .preferredColorScheme(colorSchemePreference.colorScheme)
            }
        }
    }
    
//    init() {
//        print(URL.applicationSupportDirectory.path(percentEncoded: false))
//    }
}
