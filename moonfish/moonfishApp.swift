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
        bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ0NDc0MDM1LCJ0eXBlIjoiYWNjZXNzIn0.s06BLT-jvrGxt-YDKQW0Iztp-wH08n60AgTxBLpl2PY"
    )
    
    var body: some Scene {
        WindowGroup {
            ChatListView(chatClient: chatClient)
        }
    }
}
