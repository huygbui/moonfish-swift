//
//  BackendClient.swift
//  moonfish
//
//  Created by Huy Bui on 17/2/25.
//

import Foundation
import SwiftUI

final class NetworkClient: Sendable {
    private let config: NetworkConfig
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(config: NetworkConfig = .default, session: URLSession = .shared) {
        self.config = config
        self.session = session
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
    
    func buildRequest(for endpoint: String, method: HTTPMethod = .GET, authToken: String? = nil) throws -> URLRequest {
        let url = config.baseURL.appending(components: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if method == .POST || method == .PUT || method == .PATCH {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
   
    // MARK: - Auth
    func getAuthToken(for signInRequest: AppleSignInRequest) async throws -> AuthResponse {
        var request = try buildRequest(for: "auth/apple", method: .POST)
        request.httpBody = try encoder.encode(signInRequest)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(AuthResponse.self, from: data)
    }
    
    func getSubscriptionTier(tier: String, authToken: String) async throws -> SubscriptionTierResponse {
        let request = try buildRequest(for: "subscriptions/\(tier)", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(SubscriptionTierResponse.self, from: data)
    }
    
    // MARK: - Podcasts
    func createPodcast(from podcastCreateRequest: PodcastCreateRequest, authToken: String) async throws -> PodcastResponse {
        var request = try buildRequest(for: "podcasts", method: .POST, authToken: authToken)
        request.httpBody = try encoder.encode(podcastCreateRequest)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(PodcastResponse.self, from: data)
    }
    
    
    func getPodcast(id: Int, authToken: String) async throws -> PodcastResponse {
        let request = try buildRequest(for: "podcasts/\(id)", method: .GET, authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(PodcastResponse.self, from: data)
    }
    
    func getAllPodcasts(authToken: String) async throws -> [PodcastResponse] {
        let request = try buildRequest(for: "podcasts", method: .GET, authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode([PodcastResponse].self, from: data)
    }
    
    func deletePodcast(with id: Int, authToken: String) async throws {
        let request = try buildRequest(for: "podcasts/\(id)", method: .DELETE, authToken: authToken)
        let (_, response) = try await session.data(for: request)
        
        try validateResponse(response)
    }
    
    func updatePodcast(
        with id: Int,
        from updateRequest: PodcastUpdateRequest,
        authToken: String
    ) async throws -> PodcastResponse {
        var request = try buildRequest(for: "podcasts/\(id)", method: .PATCH, authToken: authToken)
        request.httpBody = try encoder.encode(updateRequest)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(PodcastResponse.self, from: data)
    }
    
    func completeImageUpload(
        with id: Int,
        authToken: String
    ) async throws -> PodcastResponse {
        let request = try buildRequest(for: "podcasts/\(id)/upload_success", method: .POST, authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(PodcastResponse.self, from: data)
    }
   
    // MARK: - Episodes
    func getAllEpisodes(for podcastId: Int, authToken: String) async throws -> [EpisodeResponse] {
        let request = try buildRequest(for: "podcasts/\(podcastId)/episodes", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode([EpisodeResponse].self, from: data)
    }
    
    func createEpisode(from episodeRequest: EpisodeCreateRequest, podcastId: Int, authToken: String) async throws -> EpisodeResponse {
        var request = try buildRequest(for: "podcasts/\(podcastId)/episodes", method: .POST, authToken: authToken)
        request.httpBody = try encoder.encode(episodeRequest)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(EpisodeResponse.self, from: data)
    }
    
    func getAllEpisodes(authToken: String) async throws -> [EpisodeResponse] {
        let request = try buildRequest(for: "/episodes", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode([EpisodeResponse].self, from: data)
    }
    
    func getEpisode(id: Int, authToken: String) async throws -> EpisodeResponse {
        let request = try buildRequest(for: "episodes/\(id)", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(EpisodeResponse.self, from: data)
    }
    
    func getEpisodeContent(id: Int, authToken: String) async throws -> EpisodeContentResponse {
        let request = try buildRequest(for: "episodes/\(id)/content", authToken: authToken)
        let (data, response) = try await session.data(for: request)
        
        try validateResponse(response)
        return try decoder.decode(EpisodeContentResponse.self, from: data)
    }
    
    
    func deleteEpisode(id: Int, authToken: String) async throws {
        let request = try buildRequest(for: "episodes/\(id)", method: .DELETE, authToken: authToken)
        let (_, response) = try await session.data(for: request)
        
        try validateResponse(response)
    }
    
    func cancelOngoingEpisode(id: Int, authToken: String) async throws {
        let request = try buildRequest(for: "episodes/\(id)/cancel", method: .POST, authToken: authToken)
        let (_, response) = try await session.data(for: request)
        
        try validateResponse(response)
    }
   
    // MARK: - Helpers
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.unknown
        }
    }
}
