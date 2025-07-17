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
    
    init() {
        isAuthenticated = (try? Keychain.retrieveToken()) != nil
    }
    
    func signIn(appleId: String, email: String?, fullName: String?) async throws {
        let request = AppleSignInRequest(
            appleId: appleId,
            email: email,
            fullName: fullName
        )
        
        let response = try await client.getAuthToken(for: request)
        
        try Keychain.storeToken(value: response.token.accessToken)
        isAuthenticated = true
    }
    
    func signOut() throws {
        try Keychain.deleteToken()
        isAuthenticated = false
    }
}

