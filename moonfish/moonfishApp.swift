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
    @State private var audioPlayer = AudioPlayer()
    @State private var viewModel = PodcastViewModel()

    var body: some Scene {
        WindowGroup {
            Root()
                .modelContainer(SampleData.shared.modelContainer)
                .environment(audioPlayer)
                .environment(viewModel)
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
