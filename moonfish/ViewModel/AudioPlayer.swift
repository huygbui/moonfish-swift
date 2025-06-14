//
//  TestAudioPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 12/5/25.
//

import SwiftUI
import AVFoundation

@Observable
class AudioPlayer {
    var player: AVPlayer?
    var currentPodcast: Podcast?
    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var playbackRate: Double = 1.0
    
    init(currentPodcast: Podcast? = nil, isPlaying: Bool = false) {
        self.currentPodcast = currentPodcast
        self.isPlaying = isPlaying
    }

    func play(_ podcast: Podcast) {
        let url = URL(string: "http://localhost:8000/audio")!
        
        if currentPodcast == podcast && player != nil {
            if !isPlaying {
                player?.play()
                isPlaying = true
            }
            return
        }
        
        
        player = AVPlayer(url: url)
        currentPodcast = podcast
        
        // Set duration from podcast model
        duration = Double(podcast.duration)
        
        // Apply current playback rate to new player
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
}
