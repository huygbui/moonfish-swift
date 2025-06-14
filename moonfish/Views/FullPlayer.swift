//
//  FullPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct FullPlayer: View {
    @Bindable var audioPlayer: AudioPlayer
    
    @Environment(\.dismiss) private var dismiss
    @State private var playbackSpeed: Double = 1.0
    private let speedOptions: [Double] = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "waveform")
                    .font(.largeTitle)
                    .frame(width: 256, height: 256)
                    .foregroundStyle(.secondary)
                    .background(Color.secondary, in: .rect(cornerRadius: 16))
                
                // Track info
                if let currentPodcast = audioPlayer.currentPodcast {
                    VStack(spacing: 8) {
                        Text(currentPodcast.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                }
                
                // Progress slider
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { audioPlayer.currentTime },
                            set: { audioPlayer.seek(to: $0) }
                        ),
                        in: 0...audioPlayer.duration
                    )
                    
                    HStack {
                        Text(Duration.seconds(audioPlayer.currentTime), format: .time(pattern: .minuteSecond))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(Duration.seconds(audioPlayer.duration), format: .time(pattern: .minuteSecond))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Playback controls
                ZStack {
                    HStack(spacing: 32) {
                        Button(action: audioPlayer.skipBackward) {
                            Image(systemName: "gobackward.15").font(.title)
                        }
                        
                        Button {
                            if let podcast = audioPlayer.currentPodcast {
                                audioPlayer.toggle(podcast)
                            }
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 64))
                        }
                        
                        Button(action: audioPlayer.skipForward) {
                            Image(systemName: "goforward.15").font(.title)
                        }
                    }
                    
                    HStack {
                        Menu {
                            ForEach(speedOptions, id: \.self) { speed in
                                Button(action:{ playbackSpeed = speed }) {
                                    Label(formatSpeed(speed),
                                          systemImage: playbackSpeed == speed ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Text(formatSpeed(playbackSpeed))
                                .font(.title3)
                        }
                        
                        Spacer()

                        Button {
                            
                        } label: {
                            Image(systemName: "timer").font(.title3)
                        }
                        
                        
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                       dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "heart")
                    }
                }
            }
        }
    }
}

func formatSpeed(_ speed: Double) -> String {
    switch speed {
    case 0.5: return "0.5x"
    case 1.0: return "1x"
    case 1.25: return "1.25x"
    case 1.5: return "1.5x"
    case 1.75: return "1.75x"
    case 2.0: return "2x"
    default: return "\(speed)x"
    }
}

#Preview {
    let gardeningConfig = PodcastConfiguration(
        topic: "Sustainable Urban Gardening",
        length: .medium,
        level: .intermediate,
        format: .conversational,
        voice: .female
    )
    let podcast = Podcast(
        title: "Beginner's Guide to Gardening in the Far East",
        summary: "A simple guide to get you started with urban gardening.",
        transcript: "Welcome to your first step into gardening!",
        audioURL: URL(string: "https://example.com/audio/gardening_beginner.mp3")!,
        duration: 620,
        createdAt: Date(),
        configuration: gardeningConfig
    )
    let audioPlayer = AudioPlayer(currentPodcast: podcast, isPlaying: true)
    
    FullPlayer(audioPlayer: audioPlayer)
}
