//
//  FullPlayer.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI
import SwiftData

struct PlayerFull: View {
    var podcast: Podcast
    @Environment(PodcastViewModel.self) private var viewModel
    @Environment(AudioPlayer.self) private var audioPlayer
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
                
                // PodcastCover()
                
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
                        Button(action: { audioPlayer.skipBackward() }) {
                            Image(systemName: "gobackward.15")
                                .font(.title)
                        }
                        
                        Button{
                            Task {
                                await viewModel.refreshAudioURL(
                                    podcast,
                                    modelContext: context
                                )
                                audioPlayer.toggle(podcast)
                            }
                        } label: {
                            Image(systemName: audioPlayer.isPlaying(podcast) ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 64))
                        }
                        
                        Button(action: { audioPlayer.skipForward() }) {
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
                                    audioPlayer.setPlaybackRate(rate)
                                } label: {
                                    Label(
                                        formatRate(rate),
                                        systemImage: audioPlayer.playbackRate == rate ? "checkmark" : ""
                                    )
                                }
                            }
                        } label: {
                            Text(formatRate(audioPlayer.playbackRate))
                                .font(.title3)
                        }
                        
                        Spacer()
                        
                        // Sleep timer
                        Menu {
                            ForEach(viewModel.timerOptions, id: \.self) { timer in
                                Button {
                                    // viewModel.setTimer(timer: timer, audioPlayer: audioPlayer)
                                } label: {
                                    Label(
                                        formatTimer(timer),
                                        systemImage: audioPlayer.timer == timer ? "checkmark" : ""
                                    )
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
                    PodcastCardMenu(podcast: podcast)
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
    PlayerFull(podcast: .preview)
}
