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
    private let client = BackendClient()
    
    var isAuthenticated: Bool {
        token != nil
    }
    
    var token: String? {
        get { KeychainHelper.retrieve(key: tokenKey) }
        set {
            if let newValue {
                KeychainHelper.store(key: tokenKey, value: newValue)
            } else {
                KeychainHelper.delete(key: tokenKey)
            }
        }
    }
    
    func signInWithApple(appleId: String, email: String?, fullName: String?) async throws {
        let signInRequest = AppleSignInRequest(appleId: appleId, email: email, fullName: fullName)
        let authResponse = try await client.getAuthToken(for: signInRequest)
        
        // Store the token
        self.token = authResponse.token.accessToken
    }
    
    func signOut() {
        token = nil
    }
}

