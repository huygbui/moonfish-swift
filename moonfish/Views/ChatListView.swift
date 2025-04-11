//
//  ChatListView.swift
//  moonfish
//
//  Created by Huy Bui on 10/4/25.
//

import SwiftUI

struct ChatListView: View {
    @State private var isLoading: Bool = false
    @State private var chats: [Chat] = []
    
    var body: some View {
        NavigationSplitView {
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
        do {
            // This is a placeholder - we need to implement this method in ChatClient
            // chats = try await chatClient.getChats()
            // For now, let's use dummy data
            chats = [
                Chat(id: 1, title: "First Podcast", status: "Done", createdAt: "2025-04-09 17:05:10"),
                Chat(id: 2, title: "Tech News", status: "Done", createdAt: "2025-04-10 10:15:20")
            ]
        } catch {
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
    ChatListView()
}
