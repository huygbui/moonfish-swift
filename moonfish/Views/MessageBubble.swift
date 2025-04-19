//
//  SwiftUIView.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import SwiftUI

struct MessageBubble: View {
    let role : Role
    let content: String
    
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
                .padding(.horizontal)
            
            if role == .model {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        MessageBubble(role: .user, content: "Hello there!")
        MessageBubble(role: .model, content: "Hi! How can I help you?")
    }
}

