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
    private(set) var email: String?
    private let client = NetworkClient()
    
    init() {
        isAuthenticated = (try? Keychain.retrieveToken()) != nil
        email = try? Keychain.retrieveEmail()
    }
    
    func signIn(appleId: String, email: String?, fullName: String?) async throws {
        let request = AppleSignInRequest(
            appleId: appleId,
            email: email,
            fullName: fullName
        )
        
        let response = try await client.getAuthToken(for: request)
        guard let currentEmail = email ?? response.user.email else {
            throw AuthError.missing
        }
        
        try Keychain.storeToken(value: response.token.accessToken)
        try Keychain.storeEmail(value: currentEmail)
        isAuthenticated = true
    }
    
    func signOut() throws {
        try Keychain.deleteToken()
        try Keychain.deleteEmail()
        isAuthenticated = false
    }
}

enum AuthError: Error {
    case missing
}

