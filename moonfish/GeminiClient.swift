//
//  GeminiClient.swift
//  moonfish
//
//  Created by Huy Bui on 17/2/25.
//

import Foundation

enum GeminiError: Error {
    case invalidURL
    case invalidResponse
}

struct GeminiClient {
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    private let apiKey = "AIzaSyCwUpWMXdYWlSOOTeQN_7JyRjATrfsWjxI"
    
    func generate(messages: [Message]) async throws -> String {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw GeminiError.invalidURL
        }
        
        urlComponents.queryItems = [ URLQueryItem(name: "key", value: apiKey) ]
        
        guard let url = urlComponents.url else {
            throw GeminiError.invalidURL
        }
            
        let requestBody = GeminiRequest(
            contents : messages.map { $0.toGeminiMessage() }
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue( "application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GeminiError.invalidResponse
        }
        
        let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return decodedResponse.candidates.first?.content.parts.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}


struct GeminiRequest: Codable {
    let contents : [GeminiMessage]
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
    let finishReason: String
    let avgLogprobs: Double
}

struct Content: Codable {
    let parts: [Part]
    let role: String
}

struct Part: Codable {
    let text: String
}
