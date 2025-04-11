//
//  ChatListView.swift
//  moonfish
//
//  Created by Huy Bui on 10/4/25.
//

import SwiftUI

struct ChatListView: View {
    var body: some View {
        NavigationSplitView {
            List {
                ChatRowView(
                    chat: Chat(
                        id: 1,
                        title: "Moonfish",
                        status: "Done",
                        createdAt: "2025-04-09 17:05:10"
                    )
                )
                ChatRowView(
                    chat: Chat(
                        id: 1,
                        title: "Moonfish",
                        status: "Done",
                        createdAt: "2025-04-09 17:05:10"
                    )
                )
            }
            .navigationTitle(Text("Chats"))
        } detail : {
            Text("Select a chat")
        }
    }
}

#Preview {
    ChatListView()
}
