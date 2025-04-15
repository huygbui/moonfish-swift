//
//  ChatListView.swift
//  moonfish
//
//  Created by Huy Bui on 10/4/25.
//

import SwiftUI
import SwiftData

struct ChatListView: View {
    let chatClient: ChatClient
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    
    @Query(sort: \Chat.createdAt, order: .reverse) private var chats: [Chat]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(chats) { chat in
                    NavigationLink(destination: ChatView(chatClient: chatClient, chat: chat)) {
                        ChatRowView(chat: chat)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await deleteChat(chatId: chat.remoteId)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
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
            let remoteChats = try await chatClient.fetchChats()
            
            for remoteChat in remoteChats {
                // Check if this chat already exists locally
                let predicate = #Predicate<Chat> { $0.remoteId == remoteChat.id }
                let descriptor = FetchDescriptor<Chat>(predicate: predicate)
                
                if let existing = try? context.fetch(descriptor).first {
                   // Ignore for now
                } else {
                    if let newChat = Chat.init(from: remoteChat) {
                        context.insert(newChat)
                    }
                }
            }
            
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
//            chats.removeAll(where: { $0.id == chatId })
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
