//
//  TemporaryChatView.swift
//  moonfish
//
//  Created by Huy Bui on 21/4/25.
//

import SwiftUI

struct TemporaryChatView: View {
    @State private var inputText = ""
    @State private var userMessageContent = ""
    @State private var isLoading = false
    @State private var messages = [Message]()
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            MessageBubble(from: message)
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
    }
   
    @MainActor
    private func sendMessage() async {
        guard !inputText.isEmpty else { return }
        
        let userMessageContent = inputText
        let userMessage = Message(
            role: .user,
            content: userMessageContent
        )
        messages.append(userMessage)

        inputText = ""
        isLoading = true
        defer { isLoading = false }
        
        do {
            let chatResponse = try await RemoteMessageCollection.send(userMessageContent, chat: nil)
            
            let modelMessage = Message(
                id: chatResponse.id,
                role: chatResponse.role,
                content: chatResponse.content
            )
            
            messages.append(modelMessage)
        } catch {
            print("\(error.localizedDescription)")
            messages.removeLast()
        }
    }
}

#Preview {
    TemporaryChatView()
}
