//
//  ChatMessage.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import Foundation

enum Role: String, Codable {
    case assistant
    case user
}

struct Message: Identifiable, Codable {
    let id : UUID
    let role : Role
    let content : String
   
    init(id: UUID = UUID(), role: Role, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
    
    static func assistant(_ content : String) -> Message {
        Message(role: .assistant, content: content)
    }
    
    static func human(_ content : String) -> Message {
        Message(role: .user, content: content)
    }
}

extension Message {
    func toGeminiMessage() -> GeminiMessage {
        return GeminiMessage(role: role, parts: [Part(text:content)])
    }
}

struct GeminiMessage: Codable {
    let role : Role
    let parts : [Part]
}




