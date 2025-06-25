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
    @AppStorage("userIdentifier") private var userIdentifier: String = ""
    @State private var audioPlayer = AudioManager()
    @State private var podcastRootModel = PodcastViewModel()
    @State private var requestRootModel = RequestViewModel()

    private var isSignedIn: Bool { !userIdentifier.isEmpty }
    
    var body: some Scene {
        WindowGroup {
            if !isSignedIn {
                SignInView(userIdentifier: $userIdentifier)
            } else {
                Root()
                    .modelContainer(SampleData.shared.modelContainer)
                    .environment(audioPlayer)
                    .environment(podcastRootModel)
                    .environment(requestRootModel)
            }
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
