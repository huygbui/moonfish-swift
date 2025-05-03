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
    
    @Environment(\.modelContext) private var context
    @Environment(\.backendClient) private var client
    
    @State private var messages = [Message]()
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var streamingMessage: Message? = nil
    
    var body: some View {
        VStack {
            messageArea
            inputArea
        }
        .task {
            await refresh()
            messages = chat.messages.sorted(by: { $0.id < $1.id })
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
                    if isLoading {
                        if let streamingMessage, !streamingMessage.content.isEmpty {
                            MessageBubble(from: streamingMessage)
                                .id(streamingMessage.id)
                        } else {
                            ThinkingDots()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("thinkingDotsId")
                        }
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
            .onChange(of: isLoading) {
                if isLoading {
                    withAnimation {
                        if let streamingMessage {
                            proxy.scrollTo(streamingMessage.id)
                        } else {
                            proxy.scrollTo("thinkingDotsId")
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
                .disabled(isLoading)
            Button {
                Task {
                    await send()
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
}


@MainActor
extension ChatView {
    func refresh() async {
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
    
    func send() async {
        guard !inputText.isEmpty else { return }
        
        let userMessageContent = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let userMessage = Message(id: -1 * Int(Date().timeIntervalSince1970), role: .user, content: userMessageContent)
        messages.append(userMessage)
        
        inputText = ""
        isLoading = true
        defer { isLoading = false }
        
        do {
            let stream = try await client.sendMessage(userMessageContent, chatId: chat.id)
            for try await event in stream {
                switch event {
                case .start(let remoteMessage):
                    streamingMessage = Message(id: remoteMessage.id, role: .model, content: "")
                case .delta(let remoteMessageDelta):
                    if let streamingMessage {
                        streamingMessage.content.append(remoteMessageDelta.v)
                        self.streamingMessage = streamingMessage
                    }
                case .end:
                    if let streamingMessage {
                        messages.append(streamingMessage)
                        self.streamingMessage = nil
                    }
                    isLoading = false
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
