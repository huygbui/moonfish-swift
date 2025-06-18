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
    let podcast: Podcast
    private let audioPlayer: AudioPlayer
    private let client: BackendClient
    private let modelContext: ModelContext
    
    init(podcast: Podcast, audioPlayer: AudioPlayer, client: BackendClient, modelContext: ModelContext) {
        self.podcast = podcast
        self.audioPlayer = audioPlayer
        self.client = client
        self.modelContext = modelContext
    }
    
    // MARK: - Podcast Data Properties
    
    var title: String { podcast.title }
    var summary: String { podcast.summary }
    var createdAt: String { podcast.createdAt.formatted(dateStyle) }
    var duration: Duration { Duration.seconds(podcast.duration) }
    var length: String { podcast.length.localizedCapitalized }
    var format: String { podcast.format.localizedCapitalized }
    var level: String { podcast.level.localizedCapitalized }
    var isFavorite: Bool { podcast.isFavorite }
    var isDownloaded: Bool { podcast.isDownloaded }
    
    // MARK: - Computed Properties
    
    var isPlaying: Bool {
        audioPlayer.isPlaying && audioPlayer.currentPodcast == podcast
    }
    
    var playButtonImageName: String {
        isPlaying ? "pause.circle.fill" : "play.circle.fill"
    }
    
    var playButtonImageNameCompact: String {
        isPlaying ? "pause.fill" : "play.fill"
    }
    
    var favoriteImageName: String {
        isFavorite ? "heart.fill" : "heart"
    }
    
    var favoriteText: String {
        isFavorite ? "Liked" : "Like"
    }
    
    var downloadImageName: String {
        isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle"
    }
    
    var downloadText: String {
        isDownloaded ? "Downloaded" : "Download"
    }
    
    // MARK: - Actions
    
    @MainActor
    func playPause() async {
        // Check if audio URL needs refreshing
        let currentDate = Date()
        if podcast.expiresAt == nil || currentDate > podcast.expiresAt! {
            do {
                let audio = try await client.getPodcastAudio(id: podcast.taskId)
                podcast.url = audio.url
                podcast.expiresAt = audio.expiresAt
                try modelContext.save()
            } catch {
                print("Failed to fetch podcast audio: \(error)")
                return
            }
        }
        
        audioPlayer.toggle(podcast)
    }
    
    func toggleFavorite() {
        podcast.isFavorite.toggle()
        do {
            try modelContext.save()
        } catch {
            print("Failed to save favorite state: \(error)")
        }
    }
    
    func downloadPodcast() {
        podcast.isDownloaded.toggle()
        do {
            try modelContext.save()
        } catch {
            print("Failed to save download state: \(error)")
        }
    }
    
    @MainActor
    func deletePodcast() async {
        do {
            if podcast == audioPlayer.currentPodcast {
                audioPlayer.pause()
                audioPlayer.currentPodcast = nil
            }
            modelContext.delete(podcast)
            try await client.deletePodcast(id: podcast.taskId)
        } catch {
            print("Failed to delete podcast: \(error)")
        }
    }
}
