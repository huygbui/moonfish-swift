//
//  PodcastViewModel.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import Foundation
import SwiftData

@MainActor
@Observable
class PodcastViewModel {
    private let client = BackendClient()
    
    func submit(_ podcastCreateRequest: PodcastCreateRequest, authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.createPodcast(from: podcastCreateRequest, authToken: token)
            let podcast = Podcast(from: response)
            context.insert(podcast)
            try context.save()
        } catch {
            print("Failed to create podcast: \(error)")
        }
    }
    
    func refresh(authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.getAllPodcasts(authToken: token)
            
            for podcastResponse in response {
                let podcast = Podcast(from: podcastResponse)
                context.insert(podcast)
            }
            try context.save()
        } catch {
           print("Failed to refresh podcasts: \(error)")
        }
    }
}
 
