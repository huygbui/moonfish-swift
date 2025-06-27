//
//  APIConfig.swift
//  moonfish
//
//  Created by Huy Bui on 16/6/25.
//

import Foundation

final class APIConfig: Sendable {
    static let shared = APIConfig()
    
    private init() {}
  
    var baseURL: String {
        return Bundle.main.object(forInfoDictionaryKey: "BackendURL") as? String ?? ""
    }
    
#if DEBUG
    var apiToken: String? {
        return Bundle.main.object(forInfoDictionaryKey: "ApiToken") as? String
    }
#endif
}
