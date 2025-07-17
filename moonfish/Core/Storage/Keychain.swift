//
//  KeychainHelper.swift
//  moonfish
//
//  Created by Huy Bui on 16/6/25.
//

import Foundation

enum KeychainError: Error, CustomStringConvertible {
    case store(status: OSStatus)
    case read(status: OSStatus)
    case delete(status: OSStatus)
    
    var description: String {
        switch self {
        case .store(let s): return "Keychain store failed (OSStatus \(s))."
        case .read(let s):  return "Keychain read failed (OSStatus \(s))."
        case .delete(let s):return "Keychain delete failed (OSStatus \(s))."
        }
    }
}

struct Keychain {
    static func store(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else { throw KeychainError.store(status: errSecParam) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.store(status: status) }
    }
    
    static func retrieve(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.read(status: status)
        }
        return string
    }
    
    static func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.delete(status: status) }
    }
}

extension Keychain {
    static func retrieveToken() throws -> String {
        return try retrieve(key: "auth-token")
    }
    
    static func storeToken(value: String) throws {
        try store(key: "auth-token", value: value)
    }
    
    static func deleteToken() throws {
        try delete(key: "auth-token")
    }
}
