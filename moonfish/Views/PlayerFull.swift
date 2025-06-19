//
//  FullPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PlayerFull: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.backendClient) private var client: BackendClient
    @Environment(\.dismiss) private var dismiss
    @State private var playbackSpeed: Double = 1.0
    @State private var timer: Double = 0
    @State private var isPresented: Bool = false
    
    private let speedOptions: [Double] = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    private let timerOptions: [Double] = [0, 5, 10, 15, -1]

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Album art placeholder
                Image(systemName: "waveform")
                    .font(.largeTitle)
                    .frame(width: 256, height: 256)
                    .foregroundStyle(.secondary)
                    .background(Color.secondary.opacity(0.1), in: .rect(cornerRadius: 16))
                
//                PodcastCover()
                
                // Track info
                VStack(spacing: 8) {
                    Text(audioPlayer.currentPodcast?.title ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Progress slider
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { audioPlayer.currentTime },
                            set: { audioPlayer.seek(to: $0) }
                        ),
                        in: 0...max(audioPlayer.duration, 1)
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
                    // Main controls
                    HStack(spacing: 32) {
                        Button(action: audioPlayer.skipBackward) {
                            Image(systemName: "gobackward.15")
                                .font(.title)
                        }
                        
                        Button(action: audioPlayer.togglePlayback) {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 64))
                        }
                        
                        Button(action: audioPlayer.skipForward) {
                            Image(systemName: "goforward.15")
                                .font(.title)
                        }
                    }
                    
                    // Secondary controls
                    HStack {
                        // Speed control
                        Menu {
                            ForEach(speedOptions, id: \.self) { speed in
                                Button {
                                    playbackSpeed = speed
                                } label: {
                                    Label(formatSpeed(speed),
                                          systemImage: playbackSpeed == speed ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Text(formatSpeed(playbackSpeed))
                                .font(.title3)
                        }
                        
                        Spacer()
                        
                        // Sleep timer
                        Menu {
                            ForEach(timerOptions, id: \.self) { option in
                                Button {
                                    timer = option
                                } label: {
                                    Label(formatTimer(option),
                                          systemImage: timer == option ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Image(systemName: "timer")
                                .font(.title3)
                        }
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Menu", systemImage: "ellipsis") {
                        isPresented = true
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                Text("Hello")
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

private func formatSpeed(_ speed: Double) -> String {
    if speed == 1.0 {
        return "1×"
    } else {
        return "\(speed.formatted(.number.precision(.fractionLength(0...2))))×"
    }
}

private func formatTimer(_ time: Double) -> String {
    switch time {
    case 0: return "Off"
    case -1: return "End of episode"
    default: return "\(Int(time)) min"
    }
}

#Preview(traits: .audioPlayer) {
    PlayerFull()
}
