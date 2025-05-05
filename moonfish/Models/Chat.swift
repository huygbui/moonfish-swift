//
//  Chat.swift
//  moonfish
//
//  Created by Huy Bui on 14/4/25.
//

import Foundation
import SwiftData


let ISO8601 = Date.ISO8601FormatStyle()
        .year()
        .month()
        .day()
        .time(includingFractionalSeconds: false)
        .dateSeparator(.dash)
        .timeSeparator(.colon)


struct RemoteChatCollection: Decodable {
    let chats: [RemoteChat]
    
    struct RemoteChat: Decodable {
        var id: Int
        var title: String?
        var status: String
        var createdAt: String
        var updatedAt: String

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case status
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }
}

struct RemoteMessageCollection: Decodable {
    let chatId: Int
    let messages: [RemoteMessage]
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case messages
    }
}

struct RemoteMessage: Decodable {
    var id: Int
    var role: Role
    var content: String
}

enum StreamingMessageEvent {
    case start(RemoteMessageStart)
    case delta(RemoteMessageDelta)
    case end(RemoteMessageEnd)
}

struct RemoteMessageStart: Decodable {
    var id: Int
    var role: Role
    var content: String
    var chatId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case content
        case chatId = "chat_id"
    }
}

struct RemoteMessageDelta: Decodable {
    var v: String
}

struct RemoteMessageEnd: Decodable {
    var status: String
}

struct ChatRequest: Codable {
    let content: String
    let chatId: Int?
    
    enum CodingKeys: String, CodingKey {
        case content
        case chatId = "chat_id"
    }
}

enum Role: String, Codable {
    case model
    case user
}

@Model
final class Chat {
    @Attribute(.unique) var id: Int
    var title: String?
    var status: String?
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Message.chat) var messages = [Message]()
    
    init(id: Int, createdAt: Date, updatedAt: Date, title: String? = nil, status: String? = nil) {
        self.id = id
        self.title = title
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init?(from remoteChat: RemoteChatCollection.RemoteChat) {
        guard let createdAt = try? Date(remoteChat.createdAt, strategy: ISO8601),
              let updatedAt = try? Date(remoteChat.updatedAt, strategy: ISO8601)
        else {
            fatalError("Invalid date")
        }
        
        self.init(
            id: remoteChat.id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            title: remoteChat.title,
            status: remoteChat.status
        )
    }
}

@Model
final class Message {
    @Attribute(.unique) var id: Int
    var role: Role
    var content: String
    var chat: Chat?
    
    init(id: Int, role: Role, content: String, chat: Chat? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.chat = chat
    }
    
    convenience init(from remoteMessage: RemoteMessage, for chat: Chat? = nil) {
        self.init(
            id: remoteMessage.id,
            role: remoteMessage.role,
            content: remoteMessage.content,
            chat: chat
        )
    }
}


