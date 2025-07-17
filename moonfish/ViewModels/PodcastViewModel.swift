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
    private let client = NetworkClient()
    
    func submit(
        _ createRequest: PodcastCreateRequest,
        imageData: Data?,
        context: ModelContext
    ) async {
        do {
            let response = try await client.createPodcast(from: createRequest)
            
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
        context: ModelContext
    ) async {
        do {
            let response = try await client.createEpisode(from: request, podcastId: podcast.serverId)
            
            let episode = Episode(from: response, for: podcast)
            context.insert(episode)
            try context.save()
        } catch {
            print("Failed to create episode: \(error)")
        }
    }
    
    func delete(_ podcast: Podcast, context: ModelContext) async {
        do {
            try await client.deletePodcast(with: podcast.serverId)
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
        context: ModelContext
    ) async {
        do {
            var response = try await client.updatePodcast(with: podcast.serverId, from: updateRequest)
            
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
                        response = try await client.completeImageUpload(with: podcast.serverId)
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

    func refreshPodcasts(context: ModelContext) async {
        do {
            let response = try await client.getAllPodcasts()
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
    
    
    
    
    func refreshEpisodes(for podcast: Podcast, context: ModelContext) async {
        do {
            let response = try await client.getAllEpisodes(for: podcast.serverId)
            let serverIDs = Set(response.map { $0.id })
            
            for episodeResponse in response {
                let episode = Episode(from: episodeResponse, for: podcast)
                context.insert(episode)
            }
            
            let podcastID = podcast.id
            let descriptor = FetchDescriptor<Episode>(predicate: #Predicate<Episode> { $0.podcast.persistentModelID == podcastID })
            let localEpisodes = try context.fetch(descriptor)
            
            for localEpisode in localEpisodes {
                if !serverIDs.contains(localEpisode.serverId) {
                    context.delete(localEpisode)
                }
            }
            try context.save()
        } catch {
            print("Failed to refresh episodes: \(error)")
        }
    }
}
 
