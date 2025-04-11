//
//  GeminiClient.swift
//  moonfish
//
//  Created by Huy Bui on 17/2/25.
//

import Foundation

enum ChatError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
}

struct ChatRequest: Codable {
    let content: String
}

struct ChatResponse: Codable {
    let chatId: Int
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case content
    }
}

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

struct ChatClient {
    private let baseURL : URL
    private let bearerToken : String
    private let session : URLSession
    
    init(baseURL: URL, bearerToken: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.bearerToken = bearerToken
        self.session = session
    }

    func generate(content: String, chatId: Int? = nil) async throws -> ChatResponse {
        let url = baseURL
            .appending(component: "chat")
            .appending(components: chatId?.description ?? "")
        let requestBody = ChatRequest(content: content )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ChatError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(ChatResponse.self, from: data)
        } catch {
            throw ChatError.decodingError(error)
        }
    }
    
    func getChats() async throws -> [Chat] {
        let url = baseURL
            .appending(component: "chat")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ChatError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([Chat].self, from: data)
        } catch {
            throw ChatError.decodingError(error)
        }
    }
}

