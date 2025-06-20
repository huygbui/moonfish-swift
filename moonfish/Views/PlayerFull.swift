//
//  FullPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PlayerFull: View {
    var viewModel: PodcastViewModel
    @Environment(AudioPlayer.self) private var audioPlayer
    @Environment(\.backendClient) private var client: BackendClient
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isPresented: Bool = false
    
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
                    Text(viewModel.title)
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
                        Button(action: { viewModel.skipBackward(audioPlayer) }) {
                            Image(systemName: "gobackward.15")
                                .font(.title)
                        }
                        
                        Button{
                            Task {
                                await viewModel.playPause(
                                    audioPlayer: audioPlayer,
                                    client: client,
                                    modelContext: context
                                )
                            }
                        } label: {
                            Image(systemName: viewModel.isPlaying(using: audioPlayer) ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 64))
                        }
                        
                        Button(action: { viewModel.skipForward(audioPlayer) }) {
                            Image(systemName: "goforward.15")
                                .font(.title)
                        }
                    }
                    
                    // Secondary controls
                    HStack {
                        // Speed control
                        Menu {
                            ForEach(viewModel.playbackRateOptions, id: \.self) { rate in
                                Button {
                                    viewModel.setPlaybackRate(rate: rate, audioPlayer: audioPlayer)
                                } label: {
                                    Label(formatRate(rate),
                                          systemImage: viewModel.currentPlaybackRate(audioPlayer) == rate ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Text(formatRate(viewModel.currentPlaybackRate(audioPlayer)))
                                .font(.title3)
                        }
                        
                        Spacer()
                        
                        // Sleep timer
                        Menu {
                            ForEach(viewModel.timerOptions, id: \.self) { timer in
                                Button {
                                    viewModel.setTimer(timer: timer, audioPlayer: audioPlayer)
                                } label: {
                                    Label(formatTimer(timer),
                                          systemImage: viewModel.currentTimer(audioPlayer) == timer ? "checkmark" : "")
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
                    if let podcast = audioPlayer.currentPodcast {
                        let viewModel = PodcastViewModel(podcast: podcast)
                        PodcastCardMenu(viewModel: viewModel)
                    }
                }
            }
        }
    }
}

private func formatRate(_ rate: Double) -> String {
    if rate == 1.0 {
        return "1×"
    } else {
        return "\(rate.formatted(.number.precision(.fractionLength(0...2))))×"
    }
}

private func formatTimer(_ time: Double) -> String {
    switch time {
    case 0: return "Off"
    case -1: return "End of episode"
    default: return "\(Int(time)) min"
    }
}

#Preview(traits: .audioPlayerTrait) {
    let podcast = Podcast(
        taskId: 0,
        topic: "Sustainable Urban Gardening",
        length: PodcastLength.medium.rawValue,
        level: PodcastLevel.intermediate.rawValue,
        format: PodcastFormat.conversational.rawValue,
        voice: PodcastVoice.female.rawValue,
        title: "Beginner's Guide to Gardening in the Far East",
        summary: "A simple guide to get you started with urban gardening. This podcast explores practical tips for cultivating plants in small spaces, navigating the unique climates and seasons of the Far East, and selecting beginner-friendly crops suited to the region. Learn how to maximize limited space, source affordable tools, and embrace sustainable practices to create your own thriving garden, whether on a balcony, rooftop, or tiny backyard.",
//        transcript: "Welcome to your first step into gardening! This podcast, made just for you, will cover the basics...",
        fileName: "gardening_beginner.mp3",
        duration: 620, // about 10 minutes
        createdAt: Date(timeIntervalSinceNow: -86400 * 6 + 3600) // Created an hour after the request
    )
    let viewModel = PodcastViewModel(podcast: podcast)
    
    PlayerFull(viewModel: viewModel)
}
