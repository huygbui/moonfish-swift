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
    
    var body: some Scene {
        WindowGroup {
            Home()
                .modelContainer(SampleData.shared.modelContainer)
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
