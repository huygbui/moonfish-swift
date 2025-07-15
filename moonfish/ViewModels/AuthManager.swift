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
    private let client = NetworkClient()
    
    private let tokenKey = "auth-token"
    var currentToken: String? { try? Keychain.retrieve(key: tokenKey) }
    
    init() {
        isAuthenticated = (try? Keychain.retrieve(key: tokenKey)) != nil
    }
    
    func signIn(appleId: String, email: String?, fullName: String?) async throws {
        let request = AppleSignInRequest(
            appleId: appleId,
            email: email,
            fullName: fullName
        )
        
        let response = try await client.getAuthToken(for: request)
        
        try Keychain.store(key: tokenKey, value: response.token.accessToken)
        isAuthenticated = true
    }
    
    func signOut() throws {
        try Keychain.delete(key: tokenKey)
        isAuthenticated = false
    }
}

