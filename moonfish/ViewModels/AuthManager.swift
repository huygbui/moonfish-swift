//
//  AuthManager.swift
//  moonfish
//
//  Created by Huy Bui on 15/7/25.
//

import Foundation

@MainActor
@Observable
final class AuthManager {
    private(set) var isAuthenticated = false
    private let keychain = KeychainHelper.self
    private let client = NetworkClient()
    
    private enum Keys {
        static let token = "auth-token"
        static let email = "user-email"
    }
    
    var email: String? {
        keychain.retrieve(key: Keys.email)
    }
    
    var currentToken: String? {
        #if DEBUG
        return AppConfig.shared.apiToken
        #else
        return keychain.retrieve(key: Keys.token)
        #endif
    }
    
    init() {
        checkAuthenticationStatus()
    }
    
    func signIn(appleId: String, email: String?, fullName: String?) async throws -> String {
        let request = AppleSignInRequest(
            appleId: appleId,
            email: email,
            fullName: fullName
        )
        
        let response = try await client.getAuthToken(for: request)
        
        // Store credentials
        storeCredentials(token: response.token.accessToken, email: email)
        
        return response.token.accessToken
    }
    
    func signOut() {
        clearCredentials()
    }
    
    private func checkAuthenticationStatus() {
        #if DEBUG
        if AppConfig.shared.apiToken != nil {
            isAuthenticated = true
            return
        }
        #endif
        
        isAuthenticated = keychain.retrieve(key: Keys.token) != nil
    }
    
    private func storeCredentials(token: String, email: String?) {
        _ = keychain.store(key: Keys.token, value: token)
        if let email {
            _ = keychain.store(key: Keys.email, value: email)
        }
        isAuthenticated = true
    }
    
    private func clearCredentials() {
        _ = keychain.delete(key: Keys.token)
        _ = keychain.delete(key: Keys.email)
        isAuthenticated = false
    }
}

