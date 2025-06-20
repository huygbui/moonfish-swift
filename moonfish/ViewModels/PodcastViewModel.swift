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
    var duration: Duration { Duration.seconds(podcast.duration) }
    var length: String { podcast.length.localizedCapitalized }
    var format: String { podcast.format.localizedCapitalized }
    var level: String { podcast.level.localizedCapitalized }
    var isFavorite: Bool { podcast.isFavorite }
    var isDownloaded: Bool { podcast.isDownloaded }
    
    
    // MARK: - Podcast Playback Options
    
    let playbackRateOptions: [Double] = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    let timerOptions: [Double] = [0, 5, 10, 15, -1]

    
    // MARK: - Actions
    
    func toggleFavorite() {
        podcast.isFavorite.toggle()
    }
    
    func downloadPodcast() {
        podcast.isDownloaded.toggle()
    }
    
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
    
    func skipForward(_ audioPlayer: AudioPlayer) {
        if !isPlaying(using: audioPlayer) { return }
        
        audioPlayer.skipForward()
    }
    
    func skipBackward(_ audioPlayer: AudioPlayer) {
        if !isPlaying(using: audioPlayer) { return }
        
        audioPlayer.skipBackward()
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
    
    func setPlaybackRate(rate: Double, audioPlayer: AudioPlayer) {
        audioPlayer.setPlaybackRate(rate)
    }
    
    func currentPlaybackRate(_ audioPlayer: AudioPlayer) -> Double {
        return audioPlayer.playbackRate
    }
    
    func setTimer(timer: Double, audioPlayer: AudioPlayer) {
        
    }
    
    func currentTimer(_ audioPlayer: AudioPlayer) -> Double {
       return 0 
    }
}
