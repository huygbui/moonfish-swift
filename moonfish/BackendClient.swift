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
    case decodingError(String)
    case configurationError
    case unauthorized
}

struct AppleSignInRequest: Codable {
    var appleId: String
    var email: String?
    var fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case appleId = "apple_id"
        case email
        case fullName = "full_name"
    }
}

struct AuthResponse: Codable {
    let token: Token
    let user: UserInfo
}

struct Token: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

struct UserInfo: Codable {
    let id: Int
    let appleId: String
    let email: String?
    let name: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case email
        case name
        case createdAt = "created_at"
    }
}


final class BackendClient: Sendable {
    private let config = APIConfig.shared
    private let session = URLSession.shared
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            guard let date = formatter.date(from: dateString) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid ISO8601 date format"))
            }
            return date
        }
        
        self.encoder = JSONEncoder()
    }
    
    func createRequest(for endpoint: String, method: String = "GET") throws -> URLRequest {
        guard let baseURL = URL(string: config.baseURL) else {
            throw ClientError.configurationError
        }
        
        let url = baseURL.appending(components: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        return request
    }
    
    // MARK: - Retrieve Token:
    func getAuthToken(for signInRequest: AppleSignInRequest) async throws -> AuthResponse {
        var request = try createRequest(for: "auth/apple", method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(signInRequest)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(AuthResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError(error.localizedDescription)
        }
    }
   
    // MARK: - Create Podcast
    func createPodcast(config: PodcastConfig) async throws -> OngoingPodcastResponse {
        var request = try createRequest(for: "podcasts", method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(config)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(OngoingPodcastResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Get Completed Podcasts
    func getCompletedPodcasts() async throws -> [CompletedPodcastResponse] {
        let request = try createRequest(for: "podcasts/completed")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode([CompletedPodcastResponse].self, from: data)
            return result
        } catch {
            throw ClientError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Get Ongoing Podcasts
    func getOngoingPodcasts() async throws -> [OngoingPodcastResponse] {
        let request = try createRequest(for: "podcasts/ongoing")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode([OngoingPodcastResponse].self, from: data)
            return result
        } catch {
            throw ClientError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Get Single Podcast
    func getPodcast(id: Int) async throws -> CompletedPodcastResponse {
        let request = try createRequest(for: "podcasts/\(id)")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(CompletedPodcastResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Get Podcast Content
    func getPodcastContent(id: Int) async throws -> PodcastContentResponse {
        let request = try createRequest(for: "podcasts/\(id)/content")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(PodcastContentResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Get Podcast Audio
    func getPodcastAudio(id: Int) async throws -> PodcastAudioResponse {
        let request = try createRequest(for: "podcasts/\(id)/audio")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(PodcastAudioResponse.self, from: data)
            return result
        } catch {
            throw ClientError.decodingError(error.localizedDescription)
        }
    }

    // MARK: - Delete Podcast
    func deletePodcast(id: Int) async throws {
        let request = try createRequest(for: "podcasts/\(id)", method: "DELETE")
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                [200, 204].contains(httpResponse.statusCode)
        else {
            throw ClientError.networkError
        }
    }
    
    // MARK: - Cancel Podcast
    func cancelOngoingPodcast(id: Int) async throws {
        let request = try createRequest(for: "podcasts/\(id)/cancel", method: "POST")
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204
        else {
            throw ClientError.networkError
        }
    }
}
