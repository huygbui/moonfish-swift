//
//  BackendClient.swift
//  moonfish
//
//  Created by Huy Bui on 17/2/25.
//

import Foundation
import SwiftUI

enum ClientError: Error {
    case networkError
    case decodingError
    case configurationError
}

struct PodcastResponse: Codable, Identifiable {
    var id: Int
    
    var topic: String
    var length: String
    var level: String
    var format: String
    var voice: String
    var instruction: String = ""
    
    var status: String
    var step: String?
    var title: String?
    var summary: String?
    var url: String?
    var duration: Int?
    
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, topic, length, level, format, voice, instruction, status, step, title, summary, url, duration
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct OngoingPodcastResponse: Codable, Identifiable {
    var id: Int
    
    var topic: String
    var length: String
    var level: String
    var format: String
    var voice: String
    var instruction: String = ""
    
    var status: String
    var step: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, topic, length, level, format, voice, instruction, status, step
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PodcastContentResponse: Codable {
    var id: Int
    var title: String
    var summary: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, summary
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PodcastAudioResponse: Codable {
    var url: String
    var duration: Int
}

final class BackendClient: Sendable {
    private let config = APIConfig.shared
    private let session = URLSession.shared
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
    }
    
    private func createRequest(for endpoint: String, method: String = "GET") throws -> URLRequest {
        guard let baseURL = URL(string: config.baseURL) else {
            throw ClientError.configurationError
        }
        
        let url = baseURL.appending(components: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(config.apiKey, forHTTPHeaderField: "X-API-key")
        
        return request
    }
   
    // MARK: - Create Podcast
    func createPodcast(configuration: PodcastConfiguration) async throws -> PodcastResponse {
        var request = try createRequest(for: "podcasts", method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(configuration)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(PodcastResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError
        }
    }
    
    // MARK: - Get Completed Podcasts
    func getCompletedPodcasts() async throws -> [PodcastResponse] {
        let request = try createRequest(for: "podcasts/completed")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode([PodcastResponse].self, from: data)
            return result
        } catch {
            throw ClientError.decodingError
        }
    }
    
    // MARK: - Get Ongoing Podcasts
    func getOngoingPodcasts() async throws -> [OngoingPodcastResponse] {
        let request = try createRequest(for: "podcasts/ongoing")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode([OngoingPodcastResponse].self, from: data)
            return result
        } catch {
            throw ClientError.decodingError
        }
    }
    
    // MARK: - Get Single Podcast
    func getPodcast(id: Int) async throws -> PodcastResponse {
        let request = try createRequest(for: "podcasts/\(id)")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(PodcastResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError
        }
    }
    
    // MARK: - Get Podcast Content
    func getPodcastContent(id: Int) async throws -> PodcastContentResponse {
        let request = try createRequest(for: "podcasts/\(id)/content")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(PodcastContentResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError
        }
    }
    
    // MARK: - Get Podcast Audio
    func getPodcastAudio(id: Int) async throws -> PodcastAudioResponse {
        let request = try createRequest(for: "podcasts/\(id)/audio")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(PodcastAudioResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError
        }
    }
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
