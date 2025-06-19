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
    
    init(podcast: Podcast) {
        self.podcast = podcast
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
    
    // MARK: - Actions
    
    func isPlaying(using audioPlayer: AudioPlayer) -> Bool {
        return audioPlayer.isPlaying && audioPlayer.currentPodcast == podcast
    }
    
    func playPause(audioPlayer: AudioPlayer, client: BackendClient, modelContext: ModelContext) async {
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
    }
    
    func downloadPodcast() {
        podcast.isDownloaded.toggle()
    }
    
    func deletePodcast(audioPlayer: AudioPlayer, client: BackendClient, modelContext: ModelContext) async {
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
