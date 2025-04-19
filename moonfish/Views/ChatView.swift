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
    
    @State private var inputMessage = ""
    @State private var isLoading = false
   
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(chat.messages) { message in
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
                .onChange(of: chat.messages.count) {
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
        .task {
            print("Fetching messages...")
            await RemoteMessageCollection.refresh(chat: chat, context: context)
        }
    }
   
    @MainActor
    private func sendMessage() async {
        guard !inputMessage.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
       
        inputMessage = ""
        
        do {
            try await RemoteMessageCollection.send(messageContent: inputMessage, chat: chat, context: context)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}

#Preview {
    let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ1NTYyNzkzLCJ0eXBlIjoiYWNjZXNzIn0.2SuU6XEJZSXJ1e0IHcpOxNkzY1eEqz6xlXxWexRMegw"
    )
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
