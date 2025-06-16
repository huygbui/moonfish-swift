//
//  SimplePodcastRequestService.swift
//  moonfish
//
//  Created by Huy Bui on 16/6/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Service State

enum RequestState {
    case idle
    case submitting
    case processing(requestId: Int)
    case completed
    case cancelled
    case failed

    var canSubmit: Bool {
        switch self {
        case .idle, .completed, .cancelled, .failed:
            return true
        case .submitting, .processing:
            return false
        }
    }
    
    var isProcessing: Bool {
        switch self {
        case .submitting, .processing:
            return true
        default:
            return false
        }
    }
}

// MARK: - Simple Podcast Request Service

@Observable
@MainActor
final class RequestHandler {
    // Dependencies
    private let backendClient: BackendClient
    private var modelContext: ModelContext
    private let pollingInterval: TimeInterval
   
    // Observable state
    private(set) var state: RequestState = .idle
    private(set) var currentRequest: PodcastRequest?
    private(set) var progressValue: Double = 0.0
    private(set) var statusMessage: String = ""
    
    // State
    private var pollingTask: Task<Void, Never>?
    
    init(
        backendClient: BackendClient,
        modelContext: ModelContext,
        pollingInterval: TimeInterval = 30.0
    ) {
        self.backendClient = backendClient
        self.modelContext = modelContext
        self.pollingInterval = pollingInterval
    }
     
    // MARK: - Submit Request
    func submitRequest(configuration: PodcastConfiguration) async {
        guard state.canSubmit else { return }
        
        // Update state
        state = .submitting
        progressValue = 0.0
        
        do {
            // Submit to backend first
            let response = try await backendClient.createPodcast(configuration: configuration)
            
            // Create local request with server data
            let request = PodcastRequest(
                id: response.id,
                configuration: configuration,
                createdAt: response.createdAt,
                updatedAt: response.updatedAt,
            )
            
            modelContext.insert(request)
            try modelContext.save()
            currentRequest = request
            
            // Update state and start polling
            state = .processing(requestId: response.id)
            await startPolling(requestId: response.id)
            
        } catch {
            print("Failed to submit request: \(error)")
            state = .failed
            currentRequest = nil
        }
    }
    
    // MARK: - Cancel Request
    func cancelCurrentRequest() async {
        guard case .processing = state else { return }
        
        // Cancel polling
        pollingTask?.cancel()
        pollingTask = nil
        
        // Update state
        state = .cancelled
        progressValue = 0.0
        
        // Update request status in database
        if let currentRequest {
            currentRequest.status = RequestStatus.cancelled.rawValue
            currentRequest.updatedAt = Date()
            try? modelContext.save()
        }
        
        currentRequest = nil
        
        // TODO: Optionally notify backend about cancellation
        // if case .processing(let id) = state {
        //     try? await backendClient.cancelPodcast(id: id)
        // }
    }
    
    // MARK: - Polling
    private func startPolling(requestId: Int) async {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            await self?.pollLoop(requestId: requestId)
        }
    }
    
    private func pollLoop(requestId: Int) async {
        var retryCount = 0
        let maxRetries = 5
        
        while !Task.isCancelled {
            do {
                let response = try await backendClient.getPodcast(id: requestId)
                
                // Update progress
                updateProgress(from: response)
                
                // Check if completed
                if response.status == "completed" {
                    await handleCompletion(response)
                    break
                }
                
                // Reset retry count on success
                retryCount = 0
                try await Task.sleep(for: .seconds(pollingInterval))
                
            } catch {
                retryCount += 1
                if retryCount >= maxRetries {
                    state = .failed
                    currentRequest = nil
                    break
                }
                
                // Wait with exponential backoff
                let backoffDelay = min(pollingInterval * pow(2.0, Double(retryCount)), 300)
                try? await Task.sleep(for: .seconds(backoffDelay))
            }
        }
    }
    
    private func updateProgress(from response: PodcastRequestResponse) {
        // Update request in database
        if let currentRequest {
            currentRequest.status = RequestStatus(rawValue: response.status)?.rawValue ?? RequestStatus.pending.rawValue
            currentRequest.step = RequestStep(rawValue: response.step ?? "pending")?.rawValue
            currentRequest.updatedAt = response.updatedAt
            
            // Update progress value based on step
            switch response.step?.lowercased() {
            case "research":
                currentRequest.progressValue = 0.33
            case "compose":
                currentRequest.progressValue = 0.66
            case "voice":
                currentRequest.progressValue = 0.90
            default:
                currentRequest.progressValue = 0.1
            }
            
            try? modelContext.save()
        }
    }
    
    private func handleCompletion(_ response: PodcastRequestResponse) async {
        do {
            
            // Fetch content and audio
            let content = try await backendClient.getPodcastContent(id: response.id)
            let audio = try await backendClient.getPodcastAudio(id: response.id)
            
            guard let audioURL = URL(string: audio.url) else {
                throw URLError(.badURL)
            }
            
            // Create podcast
            let podcast = Podcast(
                title: content.title,
                summary: content.summary,
                transcript: content.transcript,
                audioURL: audioURL,
                duration: audio.duration,
                createdAt: content.createdAt,
                configuration: currentRequest?.configuration ?? PodcastConfiguration(
                    topic: "",
                    length: .short,
                    level: .beginner,
                    format: .narrative,
                    voice: .male
                )
            )
            
            // Update request
            if let request = currentRequest {
                request.status = RequestStatus.completed.rawValue
                request.progressValue = 1.0
                request.completedPodcast = podcast
                request.updatedAt = Date()
            }
            
            // Save to database
            modelContext.insert(podcast)
            try? modelContext.save()
            
            // Update state
            state = .completed
            progressValue = 1.0
            statusMessage = "Podcast ready!"
            
            // Clear current request after a delay
            Task {
                try? await Task.sleep(for: .seconds(2))
                if case .completed = state {
                    currentRequest = nil
                    state = .idle
                    progressValue = 0.0
                    statusMessage = ""
                }
            }
            
        } catch {
            print("Failed to complete request: \(error)")
            state = .failed
            statusMessage = "Failed to download podcast"
            currentRequest = nil
        }
    }
    
    // MARK: - Public Helpers
    
    var hasActiveRequest: Bool {
        state.isProcessing || currentRequest != nil
    }
    
    func getActiveRequest() -> PodcastRequest? {
        currentRequest
    }
}

// MARK: - Environment Integration
private struct RequestHandlerKey: EnvironmentKey {
    static var defaultValue: RequestHandler {
        fatalError("A RequestHandler must be injected into the environment.")
    }
}

extension EnvironmentValues {
    var requestHandler: RequestHandler {
        get { self[RequestHandlerKey.self] }
        set { self[RequestHandlerKey.self] = newValue }
    }
}
