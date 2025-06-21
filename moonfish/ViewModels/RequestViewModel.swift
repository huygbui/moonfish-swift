//
//  NewRequestViewModel.swift
//  moonfish
//
//  Created by Huy Bui on 21/6/25.
//

import SwiftUI
import SwiftData

@MainActor
@Observable
class RequestViewModel {
    private let client = BackendClient()
    
    var requests = [PodcastRequest]()
    
    func refresh() async {
        do {
            let response = try await client.getOngoingPodcasts()
            requests = response.map { PodcastRequest(from: $0) }
        } catch {
            print("Failed to fetch podcast requests: \(error)")
        }
    }
    
    func submitRequest(for config: PodcastConfig) async {
        do {
            let response = try await client.createPodcast(config: config)
            let newRequest = PodcastRequest(from: response)
            requests.append(newRequest)
        } catch {
            print("Failed to create podcast: \(error)")
        }
    }
    
    func cancel(_ request: PodcastRequest) async {
        requests.removeAll { $0.id == request.id }
        do {
            try await client.cancelOngoingPodcast(id: request.id)
        } catch {
            requests.append(request)
            print("Failed to cancel podcast: \(error)")
        }
    }
}
