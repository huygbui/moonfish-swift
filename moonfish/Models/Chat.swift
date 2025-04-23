//
//  Chat.swift
//  moonfish
//
//  Created by Huy Bui on 14/4/25.
//

import Foundation
import SwiftData


let sqlFormatStyle = Date.ISO8601FormatStyle()
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

extension RemoteChatCollection {
    @MainActor
    static func fetch() async throws -> RemoteChatCollection {
        let baseURL = URL(string: "http://localhost:8000")!
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ2Mjc3MTE2LCJ0eXBlIjoiYWNjZXNzIn0.Ry2tVyFdFwTSU3S69piVsoCB4rCoJ24ZtFA3hMipUuw"
        
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
            
            for remoteChat in remoteChatCollection.chats {
                if let chat = Chat(from: remoteChat) {
                    context.insert(chat)
                    try? context.save()
                }
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    @MainActor
    static func delete(_ chat: Chat, context: ModelContext) async {
        let baseURL = URL(string: "http://localhost:8000")!
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ2Mjc3MTE2LCJ0eXBlIjoiYWNjZXNzIn0.Ry2tVyFdFwTSU3S69piVsoCB4rCoJ24ZtFA3hMipUuw"
        
        let url = baseURL.appending(components: "chat", "\(chat.id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ChatError.invalidResponse
            }
            context.delete(chat)
            try? context.save()
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

enum ChatError: Error {
    case invalidResponse
}

struct ChatRequest: Codable {
    let content: String
}

struct ChatResponse: Decodable {
    var id: Int
    var role: Role
    var content: String
    var chatId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case content
        case chatId = "chat_id"
    }
}

extension RemoteMessageCollection {
    @MainActor
    static func fetch(for chatId: Int) async throws -> RemoteMessageCollection {
        let baseURL = URL(string: "http://localhost:8000")!
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ2Mjc3MTE2LCJ0eXBlIjoiYWNjZXNzIn0.Ry2tVyFdFwTSU3S69piVsoCB4rCoJ24ZtFA3hMipUuw"
        
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
    static func send(_ content: String, chat: Chat?) async throws -> ChatResponse {
        let baseURL = URL(string: "http://localhost:8000")!
        let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ2Mjc3MTE2LCJ0eXBlIjoiYWNjZXNzIn0.Ry2tVyFdFwTSU3S69piVsoCB4rCoJ24ZtFA3hMipUuw"
        
        let url = baseURL
            .appending(component: "chat")
            .appending(component: chat?.id.description ?? "")
        let requestBody = ChatRequest(
            content: content
        )
        print("Making a request to the url \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw RemoteSyncError.invalidResponse
        }
        
        guard let chatResponse = try? JSONDecoder().decode(ChatResponse.self, from: data) else {
            throw RemoteSyncError.decodingError
        }
        
        return chatResponse
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
    var updatedAt: Date?
    @Relationship(deleteRule: .cascade, inverse: \Message.chat) var messages = [Message]()
    
    init(id: Int, title: String? = nil, status: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init?(from remoteChat: RemoteChatCollection.RemoteChat) {
        guard let createdAt = try? Date(remoteChat.createdAt, strategy: sqlFormatStyle) else {
            print("Failed to parse created date")
            return nil
        }
        
        guard let updatedAt = try? Date(remoteChat.updatedAt, strategy: sqlFormatStyle) else {
            print("Failed to parse created date")
            return nil
        }
        
        self.init(
            id: remoteChat.id,
            title: remoteChat.title,
            status: remoteChat.status,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}


enum Role: String, Codable {
    case model
    case user
}

@Model
final class Message {
    @Attribute(.unique) var id: Int?
    var role: Role
    var content: String
    var chat: Chat?
    
    init(id: Int? = nil, role: Role, content: String, chat: Chat? = nil) {
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

