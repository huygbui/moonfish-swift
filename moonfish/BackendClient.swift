//
//  GeminiClient.swift
//  moonfish
//
//  Created by Huy Bui on 17/2/25.
//
import Foundation
import SwiftUI

enum ClientError: Error {
    case networkError
    case decodingError
}

struct PodcastRequestResponse: Codable {
    var id: Int
    var status: String
    var title: String?
    var step: String?
    var progress: Int
    var audioUrl: String?
    var duration: Int?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case title
        case step
        case progress
        case audioUrl = "audio_url"
        case duration
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

actor BackendClient {
    private let baseURL = URL(string: "http://localhost:8000")!
    
    private let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ4Nzc4MDk4LCJ0eXBlIjoiYWNjZXNzIn0.bH0_slBojP20PMC86N2zrMyEptxy6Y8JmNlDuD7CapA"
    private let session = URLSession.shared
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
        let customDateFormatter = DateFormatter()
        customDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        customDateFormatter.locale = Locale(identifier: "en_US_POSIX") // Good practice
        customDateFormatter.timeZone = TimeZone(identifier: "UTC")
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .formatted(customDateFormatter)
        
        self.encoder = JSONEncoder()
    }
   
    func createPodcast(configuration: PodcastConfiguration) async throws -> PodcastRequestResponse {
        let url = baseURL.appending(component: "podcast")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try encoder.encode(configuration)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(PodcastRequestResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError
        }
    }
    
//    func fetchChats() async throws -> RemoteChatCollection {
//        let url = baseURL.appending(component: "chat")
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await session.data(for: request)
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw ClientError.networkError
//        }
//        
//        do {
//            let result = try decoder.decode(RemoteChatCollection.self, from: data)
//            return result
//        } catch {
//            throw ClientError.decodingError
//        }
//    }
//    
//    func deleteChat(chatId: Int) async throws {
//        let url = baseURL.appending(components: "chat", "\(chatId)")
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
//        
//        let (_, response) = try await session.data(for: request)
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw ClientError.networkError
//        }
//    }
//    
//    func fetchMessages(for chatId: Int) async throws -> RemoteMessageCollection{
//        let url = baseURL.appending(components: "chat", "\(chatId)")
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
//    
//        guard let (data, response) = try? await URLSession.shared.data(for: request),
//              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
//        else {
//            throw ClientError.networkError
//        }
//        
//        do {
//            return try decoder.decode(RemoteMessageCollection.self, from: data)
//        } catch {
//            throw ClientError.decodingError
//        }
//    }
//    
//    func sendMessage(_ content: String, chatId: Int?) async throws -> AsyncThrowingStream<StreamingMessageEvent, Error> {
//        let url = baseURL.appending(component: "chat")
//        let requestBody = ChatRequest(content: content, chatId: chatId)
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
//        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
//        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
//        
//        request.httpBody = try JSONEncoder().encode(requestBody)
//            
//        let (bytes, response) = try await URLSession.shared.bytes(for: request)
//        guard let httpResponse = response as? HTTPURLResponse,
//                  httpResponse.statusCode == 200,
//                  httpResponse.mimeType == "text/event-stream"
//        else {
//            throw ClientError.networkError
//        }
//        
//        return AsyncThrowingStream { continuation in
//            Task {
//                do {
//                    var currentEvent: String?
//                    
//                    for try await line in bytes.lines {
//                        if line.hasPrefix("event:") {
//                            currentEvent = line.dropFirst("event:".count).trimmingCharacters(in: .whitespaces)
//                        }
//                        
//                        else if line.hasPrefix("data:") {
//                            let content = line.dropFirst("data:".count).trimmingCharacters(in: .whitespaces)
//                            
//                            switch currentEvent {
//                            case "message_start":
//                                let remoteMessageStart = try decoder.decode(RemoteMessageStart.self, from: content.data(using: .utf8)!)
//                                continuation.yield(.start(remoteMessageStart))
//                            case "delta":
//                                let delta = try decoder.decode(RemoteMessageDelta.self, from: content.data(using: .utf8)!)
//                                continuation.yield(.delta(delta))
//                            case "message_end":
//                                let remoteMessageEnd = try decoder.decode(RemoteMessageEnd.self, from: content.data(using: .utf8)!)
//                                continuation.yield(.end(remoteMessageEnd))
//                            case .none:
//                                break
//                            case .some(_ ):
//                                break
//                            }
//                        }
//                    }
//                    
//                    continuation.finish()
//                } catch {
//                    continuation.finish(throwing: error)
//                }
//            }
//        }
//    }
}

private struct BackendClientKey: EnvironmentKey {
    static let defaultValue: BackendClient = BackendClient()
}

extension EnvironmentValues {
    var backendClient: BackendClient {
        get { self[BackendClientKey.self] }
        set { self[BackendClientKey.self] = newValue }
    }
}
