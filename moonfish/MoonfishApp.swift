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
    @State private var audioManager = AudioManager()
    @State private var authManager = AuthManager()
    @State private var podcastRootModel = PodcastViewModel()
    @State private var requestRootModel = RequestViewModel()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                Root()
                    .modelContainer(SampleData.shared.modelContainer)
                    .environment(audioManager)
                    .environment(authManager)
                    .environment(podcastRootModel)
                    .environment(requestRootModel)
            } else {
                SignInView()
                    .environment(authManager)
            }
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
