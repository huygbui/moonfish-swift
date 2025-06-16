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
    case configurationError
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

final class BackendClient: Sendable {
    private let config = APIConfig.shared
    private let session = URLSession.shared
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
        let customDateFormatter = DateFormatter()
        customDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        customDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        customDateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .formatted(customDateFormatter)
        
        self.encoder = JSONEncoder()
    }
    
    private func createRequest(for endpoint: String, method: String = "GET") throws -> URLRequest {
        guard let baseURL = URL(string: config.baseURL) else {
            throw ClientError.configurationError
        }
        
        let url = baseURL.appending(component: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(config.apiKey, forHTTPHeaderField: "x-header-api-key")
        
        return request
    }
   
    func createPodcast(configuration: PodcastConfiguration) async throws -> PodcastRequestResponse {
        var request = try createRequest(for: "podcast", method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(configuration)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClientError.networkError
        }
        
        do {
            let result = try decoder.decode(PodcastRequestResponse.self, from: data)
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
