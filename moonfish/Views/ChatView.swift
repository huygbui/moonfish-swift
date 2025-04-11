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
    private let chatId: Int

    init(chatClient: ChatClient, chatId: Int) {
        self.chatClient = chatClient
        self.chatId = chatId
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
            let response = try await chatClient.generate(content: userMsgContent, chatId: chatId)
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
    ChatView(chatClient: chatClient, chatId: 1)
}
