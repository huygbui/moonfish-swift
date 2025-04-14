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
    @State private var chats: [Remote.Chat] = []
    
    var body: some View {
        NavigationSplitView {
            List(chats) { chat in
                NavigationLink(destination: ChatView(chatClient: chatClient, chat: chat)) {
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
                    NavigationLink(destination: ChatView(chatClient: chatClient)) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await loadChats()
            }
        } detail: {
            Text("Select a chat")
        }
    }
   
    @MainActor
    private func loadChats() async {
        isLoading = true
        defer { isLoading = false }
        do {
            chats = try await chatClient.fetchChats()
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
}


#Preview {
    let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ2MjQ5NTYwLCJ0eXBlIjoiYWNjZXNzIn0.4QyvQ_M-OMdjPsuExhPFYAEUWWcaEJlo3PB-zl4_Dzs"
    )
    ChatListView(chatClient: chatClient)
}
