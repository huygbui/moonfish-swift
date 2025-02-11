//
//  SwiftUIView.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import SwiftUI

struct MessageBubble: View {
    let message : ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .human {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(16)
                .padding(.horizontal)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        MessageBubble(message: .human("Hello there!"))
        MessageBubble(message: .assistant("Hi!"))
    }
}

