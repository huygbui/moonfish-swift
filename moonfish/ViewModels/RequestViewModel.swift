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
    
    var showingCreateSheet: Bool = false
    var isLoading: Bool = false
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
//        try? await Task.sleep(nanoseconds: 3_000_000_000)
        await refresh()
    }
    
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
            let _ = try await client.createPodcast(config: config)
        } catch {
           print("Failed to create podcast: \(error)")
        }
    }
}
