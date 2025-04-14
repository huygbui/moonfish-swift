//
//  ChatRow.swift
//  moonfish
//
//  Created by Huy Bui on 11/4/25.
//

import SwiftUI

struct ChatRowView: View {
    var chat: Remote.Chat
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(chat.title ?? "Chat \(chat.id)")
                Text(chat.createdAt)
            }
            Spacer()
        }
    }
}

#Preview {
    ChatRowView(
        chat: Remote.Chat(
            id: 1,
            title: "Moonfish",
            status: "Done",
            createdAt: "2025-04-09 17:05:10"
        )
    )
}
