//
//  Chat.swift
//  moonfish
//
//  Created by Huy Bui on 14/4/25.
//

import Foundation
import SwiftData


let sqlFormatStyle = Date.FormatStyle()
        .year(.defaultDigits)
        .month(.twoDigits)
        .day(.twoDigits)
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)


struct RemoteChatCollection: Decodable {
    let data: [RemoteChat]
    
    struct RemoteChat: Decodable {
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

extension RemoteChatCollection {
    @MainActor
    static func fetch() async throws -> RemoteChatCollection {
        let baseURL = URL(string: "http://localhost:8000")!
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ1NTYyNzkzLCJ0eXBlIjoiYWNjZXNzIn0.2SuU6XEJZSXJ1e0IHcpOxNkzY1eEqz6xlXxWexRMegw"
        
        let url = baseURL.appending(component: "chat")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
        else {
            throw RemoteSyncError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(RemoteChatCollection.self, from: data)
        } catch {
            throw RemoteSyncError.decodingError
        }
    }
    
    @MainActor
    static func refresh(context: ModelContext) async {
        do {
            let remoteChatCollection = try await fetch()
            
            for remoteChat in remoteChatCollection.data {
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

struct RemoteMessageCollection: Decodable {
    let data: [RemoteMessage]
}

struct RemoteMessage: Decodable {
    var id: Int
    var role: Role
    var content: String
}

struct ChatResponse: Decodable {
    var chatId: Int
    var id: Int
    var role: Role
    var content: String
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case id
        case role
        case content
    }
}

extension RemoteMessageCollection {
    @MainActor
    static func fetch(for chatId: Int) async throws -> RemoteMessageCollection {
        let baseURL = URL(string: "http://localhost:8000")!
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ1NTYyNzkzLCJ0eXBlIjoiYWNjZXNzIn0.2SuU6XEJZSXJ1e0IHcpOxNkzY1eEqz6xlXxWexRMegw"
        
        let url = baseURL.appending(components: "chat", "\(chatId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
        else {
            throw RemoteSyncError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(RemoteMessageCollection.self, from: data)
        } catch {
            throw RemoteSyncError.decodingError
        }
    }
    
    @MainActor
    static func refresh(chat: Chat, context: ModelContext) async {
        do {
            let remoteMessageCollection = try await fetch(for: chat.id)
            for remoteMessage in remoteMessageCollection.data {
                let message = Message(from: remoteMessage, for: chat)
                context.insert(message)
                try? context.save()
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    @MainActor
    static func send(messageContent: String, chat: Chat?, context: ModelContext) async throws {
        let baseURL = URL(string: "http://localhost:8000")!
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ1NTYyNzkzLCJ0eXBlIjoiYWNjZXNzIn0.2SuU6XEJZSXJ1e0IHcpOxNkzY1eEqz6xlXxWexRMegw"
        
        let url = baseURL
            .appending(component: "chat")
            .appending(component: chat?.id.description ?? "")
        let requestBody = ChatRequest(content: messageContent)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ChatError.invalidResponse
        }
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        
        let currentChat = chat ?? Chat(id: chatResponse.chatId)
        let currentMessage = Message(
            id: chatResponse.id,
            role: chatResponse.role,
            content: chatResponse.content,
            chat: currentChat
        )
        let newMessage = Message(
            id: chatResponse.id,
            role: chatResponse.role,
            content: chatResponse.content,
            chat: currentChat
        )
        context.insert(currentChat)
        context.insert(currentMessage)
        context.insert(newMessage)
        try? context.save()
    }
}

enum RemoteSyncError: Error {
    case invalidResponse
    case decodingError
}

@Model
final class Chat {
    @Attribute(.unique) var id: Int
    var title: String?
    var status: String?
    var createdAt: Date?
    @Relationship(deleteRule: .cascade, inverse: \Message.chat) var messages = [Message]()
    
    init(id: Int, title: String? = nil, status: String? = nil, createdAt: Date? = nil) {
        self.id = id
        self.title = title
        self.status = status
        self.createdAt = createdAt
    }
    
    convenience init?(from remoteChat: RemoteChatCollection.RemoteChat) {
        guard let createdAt = try? Date(remoteChat.createdAt, strategy: sqlFormatStyle) else {
            return nil
        }
        
        self.init(
            id: remoteChat.id,
            title: remoteChat.title,
            status: remoteChat.status,
            createdAt: createdAt
        )
    }
}


enum Role: String, Codable {
    case model
    case user
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

