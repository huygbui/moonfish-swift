//
//  ChatView.swift
//  moonfish
//
//  Created by Huy Bui on 16/2/25.
//

import SwiftUI
import SwiftData

enum ChatState : Equatable {
    case idle
    case loading
    case streaming(Message)
}

struct ChatView: View {
    var chat: Chat?
    
    @Environment(\.modelContext) private var context
    @Environment(\.backendClient) private var client
    
    @State private var currentChatId: Int?
    @State private var messages = [Message]()
    @State private var chatState = ChatState.idle
    @State private var inputText = ""
    
    
    init(chat: Chat? = nil) {
        self.chat = chat
        _currentChatId = State(initialValue: chat?.id)
    }
    
    var body: some View {
        VStack {
            messageArea
            inputArea
        }
        .task {
            if let currentChat = chat {
                await loadMessageHistory(for: currentChat)
            }
        }
    }
    
    private var messageArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(messages) { message in
                        MessageBubble(from: message)
                            .id(message.id)
                    }
                    
                    switch chatState {
                    case .loading:
                        ThinkingDots()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id("thinkingDotsId")
                    case .streaming(let currentMessage):
                        if currentMessage.content.isEmpty {
                            ThinkingDots()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("thinkingDotsId")
                        } else {
                          MessageBubble(from: currentMessage)
                            .id(currentMessage.id)  
                        }
                    case .idle:
                        EmptyView()
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: messages.count) {
                if let lastMessageId = messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastMessageId, anchor: .bottom)
                    }
                }
            }
            .onChange(of: chatState) { oldState, newState in
                switch newState {
                case .loading:
                    withAnimation {
                        proxy.scrollTo("thinkingDotsId")
                    }
                case .streaming(let currentMessage):
                    if !currentMessage.content.isEmpty {
                        withAnimation {
                            proxy.scrollTo(currentMessage.id)
                        }
                    }
                case .idle:
                    if let lastMessageId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastMessageId)
                        }
                    }
                }
            }
        }
    }
    
    private var inputArea: some View {
        HStack {
            TextField("Type message...", text: $inputText)
                .keyboardType(.default)
                .textFieldStyle(.roundedBorder)
                .disabled(chatState != .idle)
            Button {
                Task {
                    await send()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundStyle(.blue)
            }
            .disabled(inputText.isEmpty || chatState != .idle)
        }
        .padding()
    }
}


@MainActor
extension ChatView {
    func refreshMessageHistory(for chat: Chat) async {
        do {
            let remoteCollection = try await client.fetchMessages(for: chat.id)
            for remoteMessage in remoteCollection.messages {
                let message = Message(from: remoteMessage, for: chat)
                context.insert(message)
            }
            try? context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadMessageHistory(for chat: Chat) async {
        await refreshMessageHistory(for: chat)
        messages = chat.messages.sorted { $0.id < $1.id }
    }
    
    func send() async {
        guard !inputText.isEmpty, chatState == .idle else { return }
        
        let userMessageContent = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let userMessage = Message(id: Int(Date().timeIntervalSince1970) ,role: .user, content: userMessageContent)
        messages.append(userMessage)
        
        inputText = ""
        chatState = .loading
        defer { chatState = .idle }

        do {
            let stream = try await client.sendMessage(userMessageContent, chatId: currentChatId)
            
            for try await event in stream {
                switch event {
                case .start(let remoteMessageStart):
                    if currentChatId == nil { currentChatId = remoteMessageStart.chatId }
                    
                    let newMessage = Message(id: remoteMessageStart.id, role: .model, content: "")
                    chatState = .streaming(newMessage)
                case .delta(let remoteMessageDelta):
                    if case .streaming(var currentMessage) = chatState {
                        currentMessage.content.append(remoteMessageDelta.v)
                        chatState = .streaming(currentMessage)
                    } else {
                        print("Missing initial message start event")
                        assertionFailure()
                        return
                    }
                case .end:
                    if case .streaming(let finalMessage) = chatState, !finalMessage.content.isEmpty {
                        messages.append(finalMessage)
                        chatState = .idle
                    } else {
                        print("Final message must not be empty")
                        assertionFailure()
                        return
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    let chat = Chat(id: 19, createdAt: Date(), updatedAt: Date())
    ChatView(chat: chat)
}
