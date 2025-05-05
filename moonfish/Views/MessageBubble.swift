//
//  SwiftUIView.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import SwiftUI

struct MessageBubble: View {
    let role: Role
    let content: String
    
    init(role: Role, content: String) {
        self.role = role
        self.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    init(from message: Message) {
        self.init(role: message.role, content: message.content)
    }
    
    var body: some View {
        HStack {
            if role == .user {
                Spacer()
            }
            
            Text(content)
                .padding()
                .background(role == .user ? .blue : Color(.systemGray5))
                .foregroundStyle(role == .user ? .white : .primary)
                .cornerRadius(16)
            
            if role == .model {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        MessageBubble(from: Message(id: 1, role: .user, content: "Hello there!"))
        MessageBubble(from: Message(id: 2, role: .model, content: "Hi! How can I help you?"))
    }
}

