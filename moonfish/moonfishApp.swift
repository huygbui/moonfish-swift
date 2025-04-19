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
    let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ1OTA1NTU0LCJ0eXBlIjoiYWNjZXNzIn0.AUPYTGYgEUMLq8sukaMpX2L8vDYmUwR9hfVoHKHgk7k"
    )
    
    var body: some Scene {
        WindowGroup {
            ChatListView(chatClient: chatClient)
                .modelContainer(for: Chat.self)
        }
    }
    
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
