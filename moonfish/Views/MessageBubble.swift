//
//  SwiftUIView.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    
    init(from message: Message) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.role == .user ? .blue : Color(.systemGray5))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .cornerRadius(16)
                .padding(.horizontal)
            
            if message.role == .model {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        MessageBubble(from: Message(role: .user, content: "Hello there!"))
        MessageBubble(from: Message(role: .model, content: "Hi! How can I help you?"))
    }
}

