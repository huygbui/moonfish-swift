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
    
    var requests = [EpisodeRequest]()
    
    func refresh(authManager: AuthManager) async {
        guard let token = authManager.token else { return }

        do {
            let response = try await client.getOngoingPodcasts(authToken: token)
            requests = response.map { EpisodeRequest(from: $0) }
        } catch {
            print("Failed to fetch podcast requests: \(error)")
        }
    }
    
    func submitRequest(for episodeRequest: EpisodeCreateRequest, podcastId: Int, authManager: AuthManager) async {
        guard let token = authManager.token else { return }

        do {
            let response = try await client.createEpisode(for: episodeRequest, podcastId: podcastId, authToken: token)
            let newRequest = EpisodeRequest(from: response)
            requests.append(newRequest)
        } catch {
            print("Failed to create podcast: \(error)")
        }
    }
    
    func cancel(_ request: EpisodeRequest, authManager: AuthManager) async {
        guard let token = authManager.token else { return }

        requests.removeAll { $0.id == request.id }
        do {
            try await client.cancelOngoingPodcast(id: request.id, authToken: token)
        } catch {
            requests.append(request)
            print("Failed to cancel podcast: \(error)")
        }
    }
}
