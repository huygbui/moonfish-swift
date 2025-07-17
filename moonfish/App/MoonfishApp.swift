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
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(for: Podcast.self)
                .preferredColorScheme(colorSchemePreference.colorScheme)
        }
    }
}

struct AppRootView: View {
    @State private var auth = AuthManager()
    @State private var subscription = SubscriptionManager()
    @State private var usage = UsageManager()
    @State private var audio = AudioManager()
    
    var body: some View {
        if auth.isAuthenticated {
            MainTabView()
                .environment(auth)
                .environment(subscription)
                .environment(usage)
                .environment(audio)
                .task {
                    await subscription.refresh()
                    await usage.refresh()
                }
        } else {
            SignInView()
        }
    }
}

