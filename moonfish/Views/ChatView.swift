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
    @State private var isLoading = false
    @State private var messages = [Message]()
    @State private var streamingMessage: Message? = nil
    
    @Environment(\.modelContext) private var context
   
    var body: some View {
        VStack {
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
            messages = chat.messages.sorted(by: { $0.id < $1.id })
        }
        
    }
   
    @MainActor
    private func sendMessage() async {
        guard !inputText.isEmpty else { return }
        
        let userMessageContent = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let userMessage = Message(id: -1 * Int(Date().timeIntervalSince1970), role: .user, content: userMessageContent)
        messages.append(userMessage)

        inputText = ""
        isLoading = true
        defer { isLoading = false }
        
        let baseURL = URL(string: "http://localhost:8000")!
        let bearerToken = """
            eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\
            eyJzdWIiOiIxIiwiZXhwIjoxNzQ2NDU5ODE3LCJ0eXBlIjoiYWNjZXNzIn0.\
            b6zUkDzW0ie7WztGEV7RM7cJsGOj53qPxyTYTfANqn0
            """
        
        let url = baseURL.appending(component: "chat")
        let requestBody = ChatRequest(
            content: userMessageContent,
            chatId: chat.id
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            let (bytes, response) = try await URLSession.shared.bytes(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      httpResponse.mimeType == "text/event-stream"
            else {
                throw RemoteSyncError.invalidResponse
            }
           
            var currentEvent: RemoteMessageEvent?

            for try await line in bytes.lines {
                if line.hasPrefix("event:") {
                    let eventTypeRawValue = line.dropFirst("event:".count).trimmingCharacters(in: .whitespaces)
                    currentEvent = RemoteMessageEvent(rawValue: eventTypeRawValue)
                }
                
                else if line.hasPrefix("data:") {
                    let content = line.dropFirst("data:".count).trimmingCharacters(in: .whitespaces)
                    
                    switch currentEvent {
                    case .messageStart:
                        let remoteMessage = try JSONDecoder().decode(RemoteMessage.self, from: content.data(using: .utf8)!)
                        streamingMessage = Message(id: remoteMessage.id, role: .model, content: "")
                    case .delta:
                        let delta = try JSONDecoder().decode(RemoteMessageDelta.self, from: content.data(using: .utf8)!)
                        if let streamingMessage {
                            streamingMessage.content.append(delta.v)
                            self.streamingMessage = streamingMessage
                        }
                    case .messageEnd:
                        if let streamingMessage {
                            messages.append(streamingMessage)
                            self.streamingMessage = nil
                        }
                        isLoading = false
                    case nil:
                        break
                    }
                }
            }
        } catch {
           print("error \(error.localizedDescription)")
        }
    }
}


#Preview {
    let remoteChat = RemoteChatCollection.RemoteChat(
        id: 1,
        title: "Test Chat",
        status: "active",
        createdAt: "2023-01-01T00:00:00",
        updatedAt: "2023-01-01T00:00:00"
    )
    let chat = Chat(from: remoteChat)
    if let chat {
        ChatView(chat: chat)
    }
}
