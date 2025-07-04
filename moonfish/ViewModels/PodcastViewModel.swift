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
        colorChannels: (red: Double, green: Double, blue: Double)?,
        authManager: AuthManager,
        context: ModelContext
    ) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.createPodcast(
                from: createRequest,
                authToken: token)
            
            if let imageData {
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
                    print("Failed to upload image: \(error)")
                }
            }
            
            let podcast = Podcast(from: response)
            if let channels = colorChannels {
                podcast.colorRed = channels.red
                podcast.colorGreen = channels.green
                podcast.colorBlue = channels.blue
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
    
    func upload(
        imageData: Data,
        podcastId: Int,
        authManager: AuthManager
    ) async {
        guard let token = authManager.token else { return }
        
        do {
            let uploadURLResponse = try await client.createPodcastImageUploadURL(
                podcastId: podcastId,
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
        from updateRequest: PodcastUpdateRequest,
        colorChannels: (red: Double, green: Double, blue: Double)?,
        authManager: AuthManager,
        context: ModelContext
    ) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.updatePodcast(with: podcast.serverId, from: updateRequest, authToken: token)
            
            // Update the existing podcast instead of creating a new one
            podcast.title = response.title
            podcast.about = response.description
            podcast.format = response.format
            podcast.name1 = response.name1
            podcast.voice1 = response.voice1
            podcast.name2 = response.name2
            podcast.voice2 = response.voice2
            podcast.imageURL = response.imageURL
            podcast.updatedAt = response.updatedAt
            
            // Update color channels if provided
            if let channels = colorChannels {
                podcast.colorRed = channels.red
                podcast.colorGreen = channels.green
                podcast.colorBlue = channels.blue
            }
            
            try context.save()
        } catch {
            print("Failed to update podcast: \(error)")
        }
    }

    func refresh(authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.getAllPodcasts(authToken: token)
            
            // First, get existing podcasts to preserve local data
            let descriptor = FetchDescriptor<Podcast>()
            let existingPodcasts = try context.fetch(descriptor)
            let existingPodcastMap = Dictionary(uniqueKeysWithValues: existingPodcasts.map { ($0.serverId, $0) })
            
            for podcastResponse in response {
                let podcast: Podcast
                
                // Check if we have an existing podcast with color data
                if let existingPodcast = existingPodcastMap[podcastResponse.id] {
                    // Update fields from response but preserve color data
                    existingPodcast.title = podcastResponse.title
                    existingPodcast.about = podcastResponse.description
                    existingPodcast.format = podcastResponse.format
                    existingPodcast.name1 = podcastResponse.name1
                    existingPodcast.voice1 = podcastResponse.voice1
                    existingPodcast.name2 = podcastResponse.name2
                    existingPodcast.voice2 = podcastResponse.voice2
                    existingPodcast.imageURL = podcastResponse.imageURL
                    existingPodcast.updatedAt = podcastResponse.updatedAt
                    // colorRed, colorGreen, colorBlue are preserved
                    podcast = existingPodcast
                } else {
                    // New podcast - create it
                    podcast = Podcast(from: podcastResponse)
                    context.insert(podcast)
                }
                
                // Refresh episodes for this podcast
                await refreshEpisodes(for: podcast, authManager: authManager, context: context)
            }
            try context.save()
        } catch {
            print("Failed to refresh podcasts: \(error)")
        }
    }
    
//    func refresh(_ podcast: Podcast, authManager: AuthManager, context: ModelContext) async {
//        guard let token = authManager.token else { return }
//        
//        do {
//            let response = try await client.getPodcast(id: podcast.serverId, authToken: token)
//            let refreshedPodcast = Podcast(from: response)
//            context.insert(refreshedPodcast)
//            try context.save()
//            
//            await refreshEpisodes(for: refreshedPodcast, authManager: authManager, context: context)
//        } catch {
//            print("Failed to refresh podcasts: \(error)")
//        }
//    }
    
    func refreshEpisodes(for podcast: Podcast, authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
        
        do {
            let response = try await client.getAllEpisodes(for: podcast.serverId, authToken: token)
            for episodeResponse in response {
                let episode = Episode(from: episodeResponse, for: podcast)
                context.insert(episode)
            }
        } catch {
            print("Failed to refresh episodes: \(error)")
        }
    }
    
//    func refreshAllEpisodes(authManager: AuthManager, context: ModelContext) async {
//        guard let token = authManager.token else { return }
//        
//        do {
//            let response = try await client.getAllEpisodes(authToken: token)
//            
//            for episodeResponse in response {
//                let episode = Episode(from: episodeResponse)
//                context.insert(episode)
//            }
//        }
//    }
}
 
