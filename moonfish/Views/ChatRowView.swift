//
//  ChatRow.swift
//  moonfish
//
//  Created by Huy Bui on 11/4/25.
//

import SwiftUI

struct ChatRowView: View {
    var chat: Chat
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(chat.title ?? "Chat \(chat.id)")
                Text(chat.updatedAt?.formatted(.relative(presentation: .numeric)) ?? "")
            }
            Spacer()
        }
    }
}

#Preview {
    let remoteChat = RemoteChatCollection.RemoteChat(
        id: 1,
        title: "Moonfish",
        status: "Done",
        createdAt: "2025-04-09T17:05:10",
        updatedAt: "2025-04-09T17:05:10"
    )
    let chat = Chat(from: remoteChat)!
    
    ChatRowView(chat: chat)
}
