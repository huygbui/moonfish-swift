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
        isAuthenticated = (try? KeychainService.retrieveToken()) != nil
        email = try? KeychainService.retrieveEmail()
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
        
        try KeychainService.storeToken(value: response.token.accessToken)
        try KeychainService.storeEmail(value: currentEmail)
        isAuthenticated = true
    }
    
    func signOut() throws {
        try KeychainService.deleteToken()
        try KeychainService.deleteEmail()
        isAuthenticated = false
    }
}

enum AuthError: Error {
    case missing
}

