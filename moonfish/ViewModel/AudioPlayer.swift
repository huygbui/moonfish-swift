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

    func play(_ podcast: Podcast) {
//        let url = podcast.audioURL
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
        player?.play()
        isPlaying = true
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
        }
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
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
