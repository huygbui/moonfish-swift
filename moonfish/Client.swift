//
//  GeminiClient.swift
//  moonfish
//
//  Created by Huy Bui on 17/2/25.
//
import Foundation

enum ClientError: Error {
    case networkError
    case decodingError
}

struct Client {
    private let baseURL = URL(string: "http://localhost:8000")!
    private let bearerToken = """
        eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\
        eyJzdWIiOiIxIiwiZXhwIjoxNzQ2NDU5ODE3LCJ0eXBlIjoiYWNjZXNzIn0.\
        b6zUkDzW0ie7WztGEV7RM7cJsGOj53qPxyTYTfANqn0
        """
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    func fetchChats() async throws -> RemoteChatCollection {
        let url = baseURL.appending(component: "chat")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(RemoteChatCollection.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError
        }
    }
    
    func deleteChat(chatId: Int) async throws {
        let url = baseURL.appending(components: "chat", "\(chatId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
    }
}

