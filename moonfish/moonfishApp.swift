//
//  moonfishApp.swift
//  moonfish
//
//  Created by Huy Bui on 11/2/25.
//

import SwiftUI
import SwiftData

@main
struct moonfishApp: App {
    @State private var audioPlayer = AudioManager()
    @State private var podcastRootModel = PodcastViewModel()
    @State private var requestRootModel = RequestViewModel()
    
    var body: some Scene {
        WindowGroup {
            Root()
                .modelContainer(SampleData.shared.modelContainer)
                .environment(audioPlayer)
                .environment(podcastRootModel)
                .environment(requestRootModel)
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
