//
//  ChatView.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import SwiftUI

struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var inputMessage: String = ""
    @State private var isLoading = false
    
    private let geminiClient = GeminiClient()
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                        if isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .id("messageEnd")
                }
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .onChange(of: messages.count) {
                   withAnimation {
                        proxy.scrollTo("messageEnd")
                    }
                }
            }
            HStack {
                TextField("Type message...", text: $inputMessage)
                    .keyboardType(.default)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isLoading)
                Button {
                    Task {
                        await sendMessage()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
                .disabled(inputMessage.isEmpty || isLoading)
            }
            .padding()
        }
    }
   
    @MainActor
    private func sendMessage() async {
        guard !inputMessage.isEmpty else { return }
        
        let userMessage = Message( role: .user, content: inputMessage )
        messages.append(userMessage)
        
        inputMessage = ""
        isLoading = true
        
        do {
            let response = try await geminiClient.generate(messages: messages)
            let assistantMessage =  Message(role: .assistant, content: response)
            
            messages.append(assistantMessage)
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

#Preview {
    ChatView()
}
