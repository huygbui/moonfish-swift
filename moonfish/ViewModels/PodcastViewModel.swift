//
//  PodcastViewModel.swift
//  moonfish
//
//  Created by Huy Bui on 18/6/25.
//

import SwiftUI
import SwiftData

@MainActor
@Observable
class PodcastViewModel {
    private let client = BackendClient()
    
    let playbackRateOptions: [Double] = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    let timerOptions: [Double] = [0, 5, 10, 15, -1]
    
    func refreshAudioURL(_ podcast: Podcast, modelContext: ModelContext) async {
        if podcast.expiresAt == nil || Date() > podcast.expiresAt! {
            do {
                let audio = try await client.getPodcastAudio(id: podcast.taskId)
                podcast.url = audio.url
                podcast.expiresAt = audio.expiresAt
                try modelContext.save()
            } catch {
                print("Failed to fetch podcast audio: \(error)")
            }
        }
    }
    
    func refresh(_ context: ModelContext) async {
        do {
            let serverPodcasts = try await client.getCompletedPodcasts()
            for serverPodcast in serverPodcasts {
                if let podcast = Podcast(from: serverPodcast) {
                    context.insert(podcast)
                }
            }
            try context.save()
        } catch {
            print("Failed to fetch podcasts: \(error)")
        }
    }
    
    func delete(_ podcast: Podcast, context: ModelContext) async {
        do {
            try await client.deletePodcast(id: podcast.taskId)
            context.delete(podcast)
        } catch {
            print("Failed to delete podcast: \(error)")
        }
    }
    
    func toggleFavorite(_ podcast: Podcast) {
        podcast.isFavorite.toggle()
    }
    
    func download(_ podcast: Podcast) {
        podcast.isDownloaded.toggle()
    }
}
