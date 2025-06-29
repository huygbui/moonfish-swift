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
        _ createRequest: PodcastCreateRequest,
        coverModel: PodcastCoverModel,
        authManager: AuthManager,
        context: ModelContext
    ) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.createPodcast(
                from: createRequest,
                authToken: token)
            
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
                    print("Failed to upload image: \(error)")
                }
            }
            
            let podcast = Podcast(from: response)
            context.insert(podcast)
            try context.save()
        } catch {
            print("Failed to create podcast: \(error)")
        }
    }
    
    func submit(
        _ request: EpisodeCreateRequest,
        podcast: Podcast,
        authManager: AuthManager,
        context: ModelContext
    ) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.createEpisode(
                from: request,
                podcastId: podcast.serverId,
                authToken: token)
            
            let episode = Episode(from: response, for: podcast)
            context.insert(episode)
            try context.save()
        } catch {
            print("Failed to create episode: \(error)")
        }
    }
    
    func delete(_ podcast: Podcast, authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            try await client.deletePodcast(with: podcast.serverId, authToken: token)
            context.delete(podcast)
            try context.save()
        } catch {
            print("Failed to delete podcast: \(error)")
        }
    }

    func refresh(authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.getAllPodcasts(authToken: token)
            
            for podcastResponse in response {
                let podcast = Podcast(from: podcastResponse)
                context.insert(podcast)
                try context.save()
                
                await refreshEpisodes(for: podcast, authManager: authManager, context: context)
            }
        } catch {
           print("Failed to refresh podcasts: \(error)")
        }
    }
    
    func refreshEpisodes(for podcast: Podcast, authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.getAllEpisodes(for: podcast.serverId, authToken: token)
            
            for episodeResponse in response {
                let episode = Episode(from: episodeResponse, for: podcast)
                context.insert(episode)
            }
            try context.save()
        } catch {
            print("Failed to refresh episodes: \(error)")
        }
    }
}
 
