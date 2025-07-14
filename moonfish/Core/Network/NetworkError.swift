//
//  NetworkError.swift
//  moonfish
//
//  Created by Huy Bui on 14/7/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case noConnection
    case timeout
    case invalidRequest
    case unauthorized
    case notFound
    case serverError
    case unknown

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .invalidRequest:
            return "Invalid request"
        case .unauthorized:
            return "Not authorized"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        case .unknown:
            return "Something went wrong"
        }
    }
}
