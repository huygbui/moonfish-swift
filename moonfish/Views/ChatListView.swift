//
//  ChatListView.swift
//  moonfish
//
//  Created by Huy Bui on 10/4/25.
//

import SwiftUI
import SwiftData

struct ChatListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.backendClient) private var client

    @Query(sort: \Chat.updatedAt, order: .reverse) private var chats: [Chat]

    var body: some View {
        NavigationSplitView {
            List(chats) { chat in
                NavigationLink(destination: ChatView(chat: chat)) {
                    ChatRowView(chat: chat)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task {
                            await delete(chat)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .navigationTitle(Text("Chats"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: ChatView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await refresh()
            }
        } detail: {
            Text("Select a chat")
        }
    }
}

@MainActor
extension ChatListView {
    func delete(_ chat: Chat) async {
        do {
            try await client.deleteChat(chatId: chat.id)
            context.delete(chat)
            try? context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func refresh() async {
        do {
            let remoteCollection = try await client.fetchChats()
            
            for remoteChat in remoteCollection.chats {
                if let chat = Chat(from: remoteChat) {
                    context.insert(chat)
                    try? context.save()
                }
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}

#Preview { }
