//
//  ApplySignIn.swift
//  moonfish
//
//  Created by Huy Bui on 14/7/25.
//

import Foundation

struct AppleSignInRequest: Codable {
    var appleId: String
    var email: String?
    var fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case appleId = "apple_id"
        case email
        case fullName = "full_name"
    }
}

struct AuthResponse: Codable {
    let token: Token
    let user: User
}

struct Token: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

struct User: Codable {
    let id: Int
    let appleId: String
    let email: String?
    let name: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case email
        case name
        case createdAt = "created_at"
    }
}
