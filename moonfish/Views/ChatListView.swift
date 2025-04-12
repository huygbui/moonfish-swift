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
    @State private var errorMessage: String = ""
    @State private var chats: [Chat] = []
    
    var body: some View {
        NavigationSplitView {
            if isLoading {
                ProgressView("Loading chats..")
            } else {
                List(chats) { chat in
                    NavigationLink(destination: ChatView(chatClient: chatClient, chatId: chat.id)) {
                        ChatRowView(chat: chat)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await deleteChat(chatId: chat.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
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
    }
   
    @MainActor
    private func loadChats() async {
        isLoading = true
        defer { isLoading = false }
        do {
            chats = try await chatClient.getChats()
        } catch {
            errorMessage = "Failed to load chats: \(error.localizedDescription)"
            print(errorMessage)
        }
    }
    
    @MainActor
    private func deleteChat(chatId: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await chatClient.deleteChat(chatId: chatId)
            chats.removeAll(where: { $0.id == chatId })
        } catch {
            errorMessage = "Failed to delete chats: \(error.localizedDescription)"
            print(errorMessage)
        }
    }
    
    @MainActor
    private func createChat() async {
        isLoading = true
        defer { isLoading = false }
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
            errorMessage = "Failed to create chats: \(error.localizedDescription)"
            print(errorMessage)
        }
    }
}




#Preview {
    let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ0NDc0MDM1LCJ0eXBlIjoiYWNjZXNzIn0.s06BLT-jvrGxt-YDKQW0Iztp-wH08n60AgTxBLpl2PY"
    )
    ChatListView(chatClient: chatClient)
}
