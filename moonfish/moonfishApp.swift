//
//  moonfishApp.swift
//  moonfish
//
//  Created by Huy Bui on 11/2/25.
//

import SwiftUI

@main
struct moonfishApp: App {
    let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ2MjQ5NTYwLCJ0eXBlIjoiYWNjZXNzIn0.4QyvQ_M-OMdjPsuExhPFYAEUWWcaEJlo3PB-zl4_Dzs"
    )
    
    var body: some Scene {
        WindowGroup {
            ChatListView(chatClient: chatClient)
        }
    }
}
