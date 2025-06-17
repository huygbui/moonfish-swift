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
    case processing(requestId: Int, progress: Double = 0.0)
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
    
    var progress: Double {
        switch self {
        case .processing(_, let progress):
            return progress
        case .completed:
            return 1.0
        default:
            return 0.0
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
        state = .submitting
        
        do {
            let response = try await backendClient.createPodcast(configuration: configuration)
            
            let request = PodcastRequest(
                id: response.id,
                configuration: configuration,
                createdAt: response.createdAt,
                updatedAt: response.updatedAt,
            )
            modelContext.insert(request)
            do {
                try modelContext.save()
                currentRequest = request
                state = .processing(requestId: response.id)
            } catch {
               await handleError(error)
            }
            
            await startPolling(requestId: response.id)
        } catch {
            await handleError(error)
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
        
        // Update request status in database
        if let request = currentRequest {
            request.status = RequestStatus.cancelled.rawValue
            request.updatedAt = Date()
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
        
        while !Task.isCancelled && retryCount < maxRetries {
            do {
                let response = try await backendClient.getPodcast(id: requestId)
                
                await updateProgress(from: response)
                
                if response.status == "completed" {
                    await handleCompletion(response)
                    return
                }
                
                retryCount = 0 // Reset on success
                try await Task.sleep(for: .seconds(pollingInterval))
                
            } catch {
                retryCount += 1
                let backoffDelay = min(pollingInterval * pow(2.0, Double(retryCount)), 300)
                try? await Task.sleep(for: .seconds(backoffDelay))
            }
        }
        
        if retryCount >= maxRetries {
            await handleError(URLError(.timedOut))
        }
    }
    
    private func updateProgress(from response: PodcastCreateResponse) async {
        let progress = progressValue(for: response.step)
        state = .processing(requestId: response.id, progress: progress)
        
        guard let request = currentRequest else { return }
        
        request.status = response.status
        request.step = response.step
        request.updatedAt = response.updatedAt
        request.progressValue = progress
        
        try? modelContext.save()
    }
    
    private func handleCompletion(_ response: PodcastCreateResponse) async {
        guard let request = currentRequest else {
            await handleError(URLError(.unknown))
            return
        }
        
        do {
            // Fetch content and audio
            let content = try await backendClient.getPodcastContent(id: response.id)
            let audio = try await backendClient.getPodcastAudio(id: response.id)
            
            guard let audioURL = URL(string: audio.url) else {
                throw URLError(.badURL)
            }
            
            // Create podcast
            let podcast = Podcast(
                taskId: 0,
                configuration: request.configuration,
                title: content.title,
                summary: content.summary,
                transcript: "",
                audioURL: audioURL,
                duration: audio.duration,
                createdAt: content.createdAt,
            )
            
            // Update request
            request.status = RequestStatus.completed.rawValue
            request.progressValue = 1.0
            request.completedPodcast = podcast
            request.updatedAt = Date()
            
            // Save to database
            modelContext.insert(podcast)
            try? modelContext.save()
            
            // Update state
            state = .completed
            progressValue = 1.0
            
            // Clear current request after a delay
            Task {
                try? await Task.sleep(for: .seconds(2))
                if case .completed = state {
                    currentRequest = nil
                    state = .idle
                    progressValue = 0.0
                }
            }
            
        } catch {
            print("Failed to complete request: \(error)")
            state = .failed
            currentRequest = nil
        }
    }
    
    private func handleError(_ error: Error) async {
        print("Request failed: \(error)")
        state = .failed
        currentRequest = nil
    }
    
    private func progressValue(for step: String?) -> Double {
        switch step?.lowercased() {
        case "research": return 0.33
        case "compose": return 0.66
        case "voice": return 0.90
        default: return 0.1
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
