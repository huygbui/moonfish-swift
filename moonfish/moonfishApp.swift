//
//  moonfishApp.swift
//  moonfish
//
//  Created by Huy Bui on 11/2/25.
//

import SwiftUI

@main
struct moonfishApp: App {
    private let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ0Mjg0NzM1LCJ0eXBlIjoiYWNjZXNzIn0._sGaDmtQhlUfCtWBBcav_iC4As_Qpfo2S3wQhODb-WM"
    )
    
    var body: some Scene {
        WindowGroup { }
    }
}
