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

//"id": 0,
//"topic": "string",
//"length": "short",
//"level": "beginner",
//"format": "narrative",
//"voice": "male",
//"instruction": "string",
//"status": "pending",
//"step": "research",
//"created_at": "2025-06-16T09:13:51.264Z",
//"updated_at": "2025-06-16T09:13:51.264Z",
//"title": "string",
//"summary": "string",
//"url": "string",
//"duration": 0

struct PodcastRequestResponse: Codable {
    var id: Int
    var status: String
    var step: String?
    var createdAt: Date
    var updatedAt: Date
    var title: String?
    var summary: String?
    var url: String?
    var duration: Int?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case step
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case title
        case summary
        case url = "url"
        case duration
        
    }
}

final class BackendClient: Sendable {
    private let config = APIConfig.shared
    private let session = URLSession.shared
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
//        let customDateFormatter = DateFormatter()
//        customDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        customDateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        customDateFormatter.timeZone = TimeZone(identifier: "UTC")
        
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
   
    func createPodcast(configuration: PodcastConfiguration) async throws -> PodcastRequestResponse {
        var request = try createRequest(for: "podcasts", method: "POST")
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
