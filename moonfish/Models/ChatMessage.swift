//
//  ChatMessage.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import Foundation

enum Role: String, Codable {
    case assistant
    case human
}

struct ChatMessage: Identifiable, Codable {
    let id : UUID
    let role : Role
    let content : String
   
    init(id: UUID = UUID(), role: Role, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
    
    static func assistant(_ content : String) -> ChatMessage {
        ChatMessage(role: .assistant, content: content)
    }
    
    static func human(_ content : String) -> ChatMessage {
        ChatMessage(role: .human, content: content)
    }
}

