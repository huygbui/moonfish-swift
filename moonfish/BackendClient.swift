//
//  BackendClient.swift
//  moonfish
//
//  Created by Huy Bui on 17/2/25.
//

import Foundation
import SwiftUI

enum ClientError: Error {
    case invalidResponse
    case serverError
    case networkError
    case unexpectedError
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
    
    func createRequest(for endpoint: String, method: String = "GET", authToken: String? = nil) throws -> URLRequest {
        guard let baseURL = URL(string: config.baseURL) else {
            throw ClientError.configurationError
        }
        
        let url = baseURL.appending(components: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // MARK: - Retrieve Auth Token:
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
    
    // MARK: - Create Podcast Upload Image URL
    func createPodcastImageUploadURL(
        podcastId: Int,
        authToken: String
    ) async throws -> PodcastImageUploadURLResponse {
        var request = try createRequest(
            for: "podcasts/\(podcastId)/image_upload",
            method: "POST",
            authToken: authToken
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(PodcastImageUploadURLResponse.self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }
    
    // MARK: - Create Podcast
    func createPodcast(from podcastCreateRequest: PodcastCreateRequest, authToken: String) async throws -> PodcastCreateResponse {
        var request = try createRequest(for: "podcasts", method: "POST", authToken: authToken)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(podcastCreateRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(PodcastCreateResponse.self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }    
    }
    
    // MARK: - Get All Podcasts
    func getAllPodcasts(authToken: String) async throws -> [PodcastCreateResponse] {
        var request = try createRequest(for: "podcasts", method: "GET", authToken: authToken)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode([PodcastCreateResponse].self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }
    
    // MARK: - Get Episodes Podcasts
    func getAllEpisodes(for podcastId: Int, authToken: String) async throws -> [EpisodeResponse] {
        let request = try createRequest(for: "podcasts/\(podcastId)/episodes", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode([EpisodeResponse].self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }

   
    // MARK: - Create Episode
    func createEpisode(from episodeRequest: EpisodeCreateRequest, podcastId: Int, authToken: String) async throws -> EpisodeResponse {
        var request = try createRequest(for: "podcasts/\(podcastId)/episodes", method: "POST", authToken: authToken)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(episodeRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(EpisodeResponse.self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }    
    }
    
    // MARK: - Get Completed Episodes
    func getCompletedEpisodes(authToken: String) async throws -> [EpisodeResponse] {
        let request = try createRequest(for: "episodes/completed", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode([EpisodeResponse].self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }
    
    // MARK: - Get Ongoing Episodes
    func getOngoingPodcasts(authToken: String) async throws -> [EpisodeResponse] {
        let request = try createRequest(for: "episodes/ongoing", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode([EpisodeResponse].self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }
    
    // MARK: - Get Single Episode
    func getEpisode(id: Int, authToken: String) async throws -> EpisodeResponse {
        let request = try createRequest(for: "episodes/\(id)", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(EpisodeResponse.self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }
    
    // MARK: - Get Episode Content
    func getEpisodeContent(id: Int, authToken: String) async throws -> EpisodeContentResponse {
        let request = try createRequest(for: "episodes/\(id)/content", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(EpisodeContentResponse.self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }
    
    // MARK: - Get Episode Audio
    func getEpisodeAudio(id: Int, authToken: String) async throws -> EpisodeAudioResponse {
        let request = try createRequest(for: "episodes/\(id)/audio", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(EpisodeAudioResponse.self, from: data)
            } catch {
                throw ClientError.decodingError(error.localizedDescription)
            }
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }

    // MARK: - Delete Episode
    func deleteEpisode(id: Int, authToken: String) async throws {
        let request = try createRequest(for: "episodes/\(id)", method: "DELETE", authToken: authToken)
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200, 204:
            return
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }
    
    // MARK: - Cancel Episode
    func cancelOngoingEpisode(id: Int, authToken: String) async throws {
        let request = try createRequest(for: "episodes/\(id)/cancel", method: "POST", authToken: authToken)
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200, 204:
            return
        case 401:
            throw ClientError.unauthorized
        case 500...509:
            throw ClientError.serverError
        default:
            throw ClientError.unexpectedError
        }
    }
}
