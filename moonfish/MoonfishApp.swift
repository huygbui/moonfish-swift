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
    @State private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                RootView()
                    .modelContainer(for: Podcast.self)
                    .environment(audioManager)
                    .environment(authManager)
                    .environment(epísodeRootModel)
                    .environment(podcastRootModel)
                    .environment(subscriptionManager)
                    .preferredColorScheme(colorSchemePreference.colorScheme)
                    .task {
                        // Connect subscription manager when user is authenticated
                        await subscriptionManager.setAuthManager(authManager)
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
