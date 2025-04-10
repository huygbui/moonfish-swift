//
//  ChatMessage.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import Foundation

enum Role: String, Codable {
    case model
    case user
}

struct Message: Identifiable {
    let id : UUID
    let role : Role
    let content : String
   
    
    static func model(_ content : String) -> Message {
        Message(id: UUID(), role: .model, content: content)
    }
   
    static func user(_ content : String) -> Message {
        Message(id: UUID(), role: .user, content: content)
    }
}

