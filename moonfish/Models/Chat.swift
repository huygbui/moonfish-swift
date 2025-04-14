//
//  Chat.swift
//  moonfish
//
//  Created by Huy Bui on 14/4/25.
//

import Foundation
import SwiftData

enum Remote {
    struct Chat: Identifiable, Hashable, Codable {
        var id: Int
        var title: String?
        var status: String
        var createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case status
            case createdAt = "created_at"
        }
    }
}

@Model
final class Chat {
    var remoteId: Int
    var title: String?
    var status: String
    var createdAt: String
    
    init(remoteId: Int, title: String? = nil, status: String, createdAt: String) {
        self.remoteId = remoteId
        self.title = title
        self.status = status
        self.createdAt = createdAt
    }
    
    convenience init(from remoteChat: Remote.Chat) {
        self.init(remoteId: remoteChat.id, title: remoteChat.title, status: remoteChat.status, createdAt: remoteChat.createdAt)
    }
}
