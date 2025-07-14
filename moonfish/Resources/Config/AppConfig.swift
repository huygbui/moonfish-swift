//
//  APIConfig.swift
//  moonfish
//
//  Created by Huy Bui on 16/6/25.
//

import Foundation

struct AppConfig: Sendable {
    static let shared = AppConfig()
    
    private init() {}
  
    var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BackendURL") as? String,
              let url = URL(string: urlString) else {
            fatalError("Invalid or missing BackendURL in Info.plist")
        }
        return url
    }
    
    var apiToken: String? {
        return Bundle.main.object(forInfoDictionaryKey: "ApiToken") as? String
    }
}
