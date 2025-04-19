//
//  ChatView.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import SwiftUI
import SwiftData
struct ChatView: View {
    var chat: Chat
    
    @State private var inputText = ""
    @State private var userMessageContent = ""
    @State private var isLoading = false
   
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack {
            let messages = chat.messages.sorted { $0.id < $1.id }
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            MessageBubble(
                                role: message.role,
                                content: message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                            )
                        }
                        if !userMessageContent.isEmpty {
                            MessageBubble(
                                role: .user,
                                content: userMessageContent.trimmingCharacters(in: .whitespacesAndNewlines)
                            )
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
                TextField("Type message...", text: $inputText)
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
                .disabled(inputText.isEmpty || isLoading)
            }
            .padding()
        }
        .task {
            await RemoteMessageCollection.refresh(chat: chat, context: context)
        }
    }
   
    @MainActor
    private func sendMessage() async {
        guard !inputText.isEmpty else { return }
        
        userMessageContent = inputText

        inputText = ""
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await RemoteMessageCollection.send(userMessageContent, chat: chat, context: context)
            userMessageContent = ""
        } catch {
            print("\(error.localizedDescription)")
            chat.messages.removeLast()
        }
    }
}

#Preview {
    let remoteChat = RemoteChatCollection.RemoteChat(
        id: 1,
        title: "Test Chat",
        status: "active",
        createdAt: "2023-01-01 00:00:00"
    )
    let chat = Chat(from: remoteChat)
    if let chat {
        ChatView(chat: chat)
    }
}
