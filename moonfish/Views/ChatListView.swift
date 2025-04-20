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
    
    @Query private var chats: [Chat]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationSplitView {
            List(chats) { chat in
                NavigationLink(destination: ChatView(chat: chat)) {
                    ChatRowView(chat: chat)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task {
                            await deleteChat(chat)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .navigationTitle(Text("Chats"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: ChatView(chat: nil)) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await RemoteChatCollection.refresh(context: context)
            }
        } detail: {
            Text("Select a chat")
        }
    }
   
    @MainActor
    private func deleteChat(_ chat: Chat) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await chatClient.deleteChat(chatId: chat.id)
            context.delete(chat)
            try? context.save()
        } catch {
            errorMessage = "Failed to delete chats: \(error.localizedDescription)"
            print(errorMessage)
        }
    }
}


#Preview {
    let chatClient = ChatClient(
        baseURL: URL(string: "http://localhost:8000")!,
        bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ1OTA1NTU0LCJ0eXBlIjoiYWNjZXNzIn0.AUPYTGYgEUMLq8sukaMpX2L8vDYmUwR9hfVoHKHgk7k"
    )
    ChatListView(chatClient: chatClient)
}
