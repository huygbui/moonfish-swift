//
//  ChatListView.swift
//  moonfish
//
//  Created by Huy Bui on 10/4/25.
//

import SwiftUI

struct ChatListView: View {
    let chatClient: ChatClient
    @State private var isLoading: Bool = false
    @State private var chats: [Chat] = []
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationSplitView {
            if isLoading {
                ProgressView("Loading chats..")
            } else {
                List(chats) { chat in
                    ChatRowView(chat: chat)
                }
                .refreshable {
                    await loadChats()
                }
                .navigationTitle(Text("Chats"))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            Task {
                                await createChat()
                            }
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        } detail: {
            Text("Select a chat")
        }
        .task {
            await loadChats()
        }
        .alert(
            "Error",
            isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            ),
            actions: { Button("OK", role: .cancel) { } },
            message: { Text(errorMessage ?? "") }
        )
    }
   
    @MainActor
    private func loadChats() async {
        isLoading = true
        do {
            chats = try await chatClient.getChats()
        } catch {
            errorMessage = "Failed to load chats: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    @MainActor
    private func createChat() async {
        isLoading = true
        do {
            // This is a placeholder - we need to implement this method in ChatClient
            // let newChat = try await chatClient.createChat(content: "What would you like to talk about?")
            // For now, let's use dummy data
            let newChat = Chat(
                id: chats.count + 1,
                title: "New Podcast \(chats.count + 1)",
                status: "Pending",
                createdAt: "2025-04-11 \(String(format: "%02d", Int.random(in: 0...23))):\(String(format: "%02d", Int.random(in: 0...59))):00"
            )
            chats.insert(newChat, at: 0)
        } catch {
        }
        isLoading = false
    }
}




#Preview {
    let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ0NDc0MDM1LCJ0eXBlIjoiYWNjZXNzIn0.s06BLT-jvrGxt-YDKQW0Iztp-wH08n60AgTxBLpl2PY"
    )
    ChatListView(chatClient: chatClient)
}
