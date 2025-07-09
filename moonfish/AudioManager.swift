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
final class AudioManager {
    private(set) var timer: Double = 0.0
    private(set) var playbackRate: Double = 1.0
    private(set) var currentEpisode: Episode?
    private(set) var currentTime: Double = 0.0
    private(set) var duration: Double = 0.0
    
    private let player = AVPlayer()
    private var timeObserver: Any?
    private var observationTask: Task<Void, Never>?  // New: For async observation

    init() {
        setupAudioSession()
        addPeriodicTimeObserver()
    }
    
    var isPlaying: Bool {
        player.timeControlStatus == .playing
    }
    
    var currentProgress: Double {
        guard duration > 0 else { return 0 }
        return min(currentTime / duration, 1.0)
    }
    
    var timeRemaining: Double {
        guard duration > 0 else { return 0 }
        return duration - currentTime
    }
    
    func play(_ episode: Episode) {
        guard let url = episode.playbackURL else { return }
       
        // Resume
        if currentEpisode == episode {
            if !isPlaying {
                player.play()
            }
            return
        }
        
        currentTime = 0.0
        duration = 0.0
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        currentEpisode = episode

        player.rate = Float(playbackRate)
        player.play()
        
        startObservingPlaybackEnd()
    }

    func pause() {
        player.pause()
    }
    
    func toggle(_ episode: Episode) {
        if isPlaying && currentEpisode == episode {
            pause()
        } else {
            play(episode)
        }
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime)
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
        player.rate = Float(rate)
    }
    
    func isPlaying(_ episode: Episode) -> Bool {
        currentEpisode == episode && isPlaying
    }
    
    func handleDeletion(of episode: Episode) {
        guard episode == currentEpisode else { return }
        resetPlayer()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            
            MainActor.assumeIsolated {
                currentTime = time.seconds
                duration = player.currentItem?.duration.seconds ?? 0.0
            }
        }
    }
    
    private func removePeriodicTimeObserver() {
        guard let timeObserver else { return }
        player.removeTimeObserver(timeObserver)
        self.timeObserver = nil
    }
    
    private func resetPlayer() {
        stopObserving()
        player.pause()
        player.replaceCurrentItem(with: nil)
        
        currentEpisode = nil
        currentTime = 0.0
        duration = 0.0
    }
    
    
    private func startObservingPlaybackEnd() {
        observationTask?.cancel()
        
        observationTask = Task {
            for await _ in NotificationCenter.default.notifications(named: .AVPlayerItemDidPlayToEndTime, object: player.currentItem) {
                // When playback ends, just reset to beginning and pause
                seek(to: 0)
            }
        }
    }
    
    func stopObserving() {
        observationTask?.cancel()
        observationTask = nil
    }
}
