//
//  AuthManager.swift
//  moonfish
//
//  Created by Huy Bui on 26/6/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class AuthManager {
    private let tokenKey = "auth-token"
    private let emailKey = "user-email"
    private let client = BackendClient()
    
    private(set) var isAuthenticated: Bool = false

    var token: String? {
        get { KeychainHelper.retrieve(key: tokenKey) }
        set {
            if let newValue {
                _ = KeychainHelper.store(key: tokenKey, value: newValue)
                isAuthenticated = true
            } else {
                _ = KeychainHelper.delete(key: tokenKey)
                isAuthenticated = false
            }
        }
    }
    
    var email: String? {
        get { KeychainHelper.retrieve(key: emailKey) }
        set {
            if let newValue {
                _ = KeychainHelper.store(key: emailKey, value: newValue)
            } else {
                _ = KeychainHelper.delete(key: emailKey)
            }
        }
    }
    
    init() {
        // Check initial authentication state
        isAuthenticated = KeychainHelper.retrieve(key: tokenKey) != nil
    }

    func signInWithApple(appleId: String, email: String?, fullName: String?) async throws {
        let signInRequest = AppleSignInRequest(appleId: appleId, email: email, fullName: fullName)
        let authResponse = try await client.getAuthToken(for: signInRequest)
        
        // Store the token
        self.token = authResponse.token.accessToken
        self.email = email
    }
    
    func signOut() {
        token = nil
        email = nil
    }
}

