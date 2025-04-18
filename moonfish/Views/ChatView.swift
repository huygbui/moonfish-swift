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

    private let chatClient: ChatClient
    private let chat: API.Chat?

    init(chatClient: ChatClient, chat: API.Chat? = nil) {
        self.chatClient = chatClient
        self.chat = chat
    }
    
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
        
        let userMsgContent = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        messages.append(.user(userMsgContent))
        
        inputMessage = ""
        isLoading = true
        
        do {
            let response = try await chatClient.generate(content: userMsgContent, chatId: chat?.id)
            let modelMsgContent = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            messages.append(.model(modelMsgContent))
        } catch {
        }
        
        isLoading = false
    }
}

#Preview {
    let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ0Mzg1NzMxLCJ0eXBlIjoiYWNjZXNzIn0.a6H36Rc3anjASyiteXoSx2hoXafP9USMXuWeNeklB5c"
    )
    let chat = API.Chat(
        id: 1,
        title: "Test Chat",
        status: "active",
        createdAt: "2023-01-01T00:00:00Z"
    )
    ChatView(chatClient: chatClient, chat: chat)
}
