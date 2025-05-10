//
//  ChatListView.swift
//  moonfish
//
//  Created by Huy Bui on 10/4/25.
//

import SwiftUI
import SwiftData

struct Drafts: View {
    @Environment(\.modelContext) private var context
    @Environment(\.backendClient) private var client

    @Query(sort: \Chat.updatedAt, order: .reverse) private var chats: [Chat]
    
    @State private var isPresenting: Bool = false

    var body: some View {
        NavigationSplitView {
            ZStack(alignment: .bottomTrailing){
                List(chats) { chat in
                    NavigationLink {
                        ChatView(chat: chat)
                    } label: {
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
                .task {
                    await refresh()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresenting.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a chat")
        }
        .fullScreenCover(isPresented: $isPresenting) {
            CreatePodcastTask()
        }
    }
}

@MainActor
extension Drafts {
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

#Preview {
   Drafts()
}
