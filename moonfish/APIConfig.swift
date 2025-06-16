//
//  APIConfig.swift
//  moonfish
//
//  Created by Huy Bui on 16/6/25.
//

import Foundation

final class APIConfig: Sendable {
    static let shared = APIConfig()
    
    private let apiKeyName = "x-header-api-key"
    
    private init() {
        // Setup immediately on first access
        setupAPIKeyIfNeeded()
    }
    
    private func setupAPIKeyIfNeeded() {
        // Only setup if key doesn't exist in keychain
        if KeychainHelper.retrieve(key: apiKeyName) == nil {
            setupAPIKey()
        }
    }
    
    private func setupAPIKey() {
        let bundleKey: String?
        bundleKey = Bundle.main.object(forInfoDictionaryKey: "APIKey") as? String
        
        guard let key = bundleKey,
              !key.isEmpty,
              key != "$(API_KEY)" else {
            print("Warning: No API key found in bundle configuration")
            return
        }
        
        if KeychainHelper.store(key: apiKeyName, value: key) {
            print("API key stored to keychain")
        } else {
            print("Failed to store API key to keychain")
        }
    }
    
    var apiKey: String {
        guard let key = KeychainHelper.retrieve(key: apiKeyName) else {
            fatalError("API key not found. Check your configuration.")
        }
        return key
    }
    
    var baseURL: String {
        return Bundle.main.object(forInfoDictionaryKey: "BackendURL") as? String ?? ""
    }
    
    func updateAPIKey(_ newKey: String) -> Bool {
        return KeychainHelper.store(key: apiKeyName, value: newKey)
    }
}
