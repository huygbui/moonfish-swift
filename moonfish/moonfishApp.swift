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
    
    var body: some Scene {
        WindowGroup {
            ChatListView()
                .modelContainer(for: Chat.self)
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
