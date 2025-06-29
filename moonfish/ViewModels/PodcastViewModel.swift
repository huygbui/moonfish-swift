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
    
    func submit(
        _ podcastCreateRequest: PodcastCreateRequest,
        coverModel: PodcastCoverModel, // Pass the model as parameter
        authManager: AuthManager,
        context: ModelContext
    ) async {
        guard let token = authManager.token else { return }
        
        do {
            // 1. Create podcast
            let response = try await client.createPodcast(
                from: podcastCreateRequest,
                authToken: token
            )
            
            // 2. Upload image if available
            if let imageData = coverModel.imageData { // Use coverModel parameter
                do {
                    let uploadURLResponse = try await client.createPodcastImageUploadURL(
                        podcastId: response.id,
                        authToken: token
                    )
                    
                    var request = URLRequest(url: uploadURLResponse.url)
                    request.httpMethod = "PUT"
                    request.httpBody = imageData
                    request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                    
                    let (_, _) = try await URLSession.shared.data(for: request)
                } catch {
                    // Log but don't fail podcast creation
                    print("Image upload failed: \(error)")
                }
            }
            
            // 3. Save podcast locally
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
    
    func fetchEpisodes(for podcast: Podcast, authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.getAllEpisodes(for: podcast.serverId, authToken: token)
            
            for episodeResponse in response {
                if let episode = Episode(from: episodeResponse, for: podcast) {
                    context.insert(episode)
                }
            }
            try context.save()
        } catch {
            print("Failed to refresh podcasts: \(error)")
        }
    }
}
 
