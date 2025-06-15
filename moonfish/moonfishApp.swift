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
    let client = BackendClient()
    @State private var audioPlayer = AudioPlayer.shared

    var body: some Scene {
        WindowGroup {
            Root()
                .modelContainer(SampleData.shared.modelContainer)
                .environment(\.backendClient, client)
                .environment(audioPlayer)
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
