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
    @AppStorage("colorSchemePreference") private var colorSchemePreference = ColorSchemePreference.automatic
    @State private var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(for: Podcast.self)
                .environment(sessionManager)
                .preferredColorScheme(colorSchemePreference.colorScheme)
        }
    }
}

struct AppRootView: View {
    @Environment(SessionManager.self) private var sessionManager
    @State private var episodeViewModel = EpisodeViewModel()
    @State private var podcastViewModel = PodcastViewModel()
    @State private var audioManager = AudioManager()
    
    var body: some View {
        if sessionManager.isAuthenticated {
            MainTabView()
                .environment(audioManager)
                .environment(episodeViewModel)
                .environment(podcastViewModel)
        } else {
            SignInView()
        }
    }
}

