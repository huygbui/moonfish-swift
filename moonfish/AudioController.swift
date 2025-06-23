//
//  TestAudioPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 12/5/25.
//

import SwiftUI
import AVFoundation

@Observable
@MainActor
final class AudioController {
    var player: AVPlayer?
    
    var currentPodcast: Podcast?
    var isPlaying = false
    
    var currentTime: Double = 0
    var duration: Double = 0
    var playbackRate: Double = 1.0
    var timer: Double = 0.0
    
    private var timeObserverToken: Any?
    private var url: URL?

    init() { setupAudioSession() }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    func play(_ podcast: Podcast) {
        let url = (podcast.downloadState == .completed &&
                   FileManager.default.fileExists(atPath: podcast.fileURL.path))
                   ? podcast.fileURL
                   : podcast.url

        guard let url else { return }
        
        if currentPodcast == podcast && player != nil {
            if !isPlaying {
                player?.play()
                isPlaying = true
            }
            return
        }
        
        // Clean up previous observer
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        
        player = AVPlayer(url: url)
        currentPodcast = podcast
        duration = Double(podcast.duration)
        
        // Add time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                self?.currentTime = time.seconds
            }
        }
        
        player?.rate = Float(playbackRate)
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func toggle(_ podcast: Podcast) {
        if isPlaying && currentPodcast == podcast {
            pause()
        } else {
            play(podcast)
        }
    }
    
    func togglePlayback() {
        if let podcast = currentPodcast {
            toggle(podcast)
        }
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
    }
    
    func skipForward() {
        let newTime = min(currentTime + 15, duration)
        seek(to: newTime)
    }
    
    func skipBackward() {
        let newTime = max(currentTime - 15, 0)
        seek(to: newTime)
    }
    
    func setPlaybackRate(_ rate: Double) {
        playbackRate = rate
        if isPlaying {
            player?.rate = Float(rate)
        }
    }
    
    func isPlaying(_ podcast: Podcast) -> Bool {
        currentPodcast == podcast && isPlaying
    }
}
