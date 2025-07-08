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
        imageData: Data?,
        authManager: AuthManager,
        context: ModelContext
    ) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.createPodcast(
                from: createRequest,
                authToken: token)
            
            let podcast = Podcast(from: response)
            
            if let imageData,
               let uploadURL = response.imageUploadURL {
                do {
                    var request = URLRequest(url: uploadURL)
                    request.httpMethod = "PUT"
                    request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                    request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")

                    let (_, _) = try await URLSession.shared.upload(for: request, from: imageData)
                } catch {
                    print("Failed to upload image: \(error)")
                }
            }
            
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
    
    func update(
        _ podcast: Podcast,
        updateRequest: PodcastUpdateRequest,
        imageData: Data?,
        authManager: AuthManager,
        context: ModelContext
    ) async {
        guard let token = authManager.token else { return }
        
        do {
            var response = try await client.updatePodcast(with: podcast.serverId, from: updateRequest, authToken: token)
            
            if let imageData,
               let uploadURL = response.imageUploadURL {
                do {
                    var request = URLRequest(url: uploadURL)
                    request.httpMethod = "PUT"
                    request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                    request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")

                    let (_, uploadResponse) = try await URLSession.shared.upload(for: request, from: imageData)
                    
                    if let httpResponse = uploadResponse as? HTTPURLResponse,
                       (200...299).contains(httpResponse.statusCode) {
                        response = try await client.completeImageUpload(with: podcast.serverId, authToken: token)
                    }
                } catch {
                    print("Failed to upload new image: \(error)")
                }
            }
          
            let updatedPodcast = Podcast(from: response)
            context.insert(updatedPodcast)
            try context.save()
        } catch {
            print("Failed to update podcast: \(error)")
        }
    }

    func refreshPodcasts(authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.getAllPodcasts(authToken: token)
            let serverIDs = Set(response.map { $0.id })
            
            for podcastResponse in response {
                let podcast = Podcast(from: podcastResponse)
                context.insert(podcast)
            }
            
            let descriptor = FetchDescriptor<Podcast>()
            let localPodcasts = try context.fetch(descriptor)
            
            for localPodcast in localPodcasts {
                if !serverIDs.contains(localPodcast.serverId) {
                    context.delete(localPodcast)
                }
            }
            
            try context.save()
        } catch {
            print("Failed to refresh podcasts: \(error)")
        }
    }
    
    func refreshEpisodes(authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let descriptor = FetchDescriptor<Podcast>()
            let podcasts = try context.fetch(descriptor)
            
            for podcast in podcasts {
                let response = try await client.getAllEpisodes(for: podcast.serverId, authToken: token)
                for episodeResponse in response {
                    let episode = Episode(from: episodeResponse, for: podcast)
                    context.insert(episode)
                }
            }
            try context.save()
        } catch {
            print("Failed to refresh episodes: \(error)")
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
 
