//
//  ChatListView.swift
//  moonfish
//
//  Created by Huy Bui on 10/4/25.
//

import SwiftUI
import SwiftData

struct ChatListView: View {
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
                            await RemoteChatCollection.delete(chat, context: context)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .navigationTitle(Text("Chats"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: TemporaryChatView()) {
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
}

#Preview { }
