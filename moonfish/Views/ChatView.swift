//
//  ChatView.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputMessage: String = ""
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                        .id("messageEnd")
                    }
                }
                .onChange(of: messages.count) {
                   withAnimation {
                        proxy.scrollTo("messageEnd")
                    }
                }
            }
            HStack {
                TextField("Type message...", text: $inputMessage)
                    .textFieldStyle(.roundedBorder)
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
                .disabled(inputMessage.isEmpty)
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        
        let userMessage = ChatMessage( role: .human, content: inputMessage )
        messages.append(userMessage)
        
        let currentInput = inputMessage
        inputMessage = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = "You said: \(currentInput)"
            let assistantMessage = ChatMessage( role: .assistant, content: response )
            messages.append(assistantMessage)
        }
    }
    
}

#Preview {
    ChatView()
}
