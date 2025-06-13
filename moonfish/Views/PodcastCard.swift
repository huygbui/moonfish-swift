//
//  PodcastRequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI

struct PodcastCard: View {
    var podcastRequest: PodcastRequest
    var audioPlayer: AudioPlayer? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading) {
                // Card title
                HStack(spacing: 16) {
                    Text(podcastRequest.title ?? "Untitled")
                        .font(.body)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                
                // Card subtitle
                HStack {
                    Text(podcastRequest.configuration.length.displayName)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                    Text(podcastRequest.configuration.format.displayName)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                    Text(podcastRequest.configuration.level.displayName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                if let audioPlayer, podcastRequest.status == RequestStatus.completed.rawValue,
                   let podcast = podcastRequest.completedPodcast {
                    Button(action: { audioPlayer.toggle(podcast) }) {
                        Image(systemName: audioPlayer.isPlaying && audioPlayer.currentPodcast == podcast ? "pause.circle.fill" :"play.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                    Text(Duration.seconds(podcast.duration), format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView(value: podcastRequest.progressValue)
                        .progressViewStyle(GaugeProgressStyle())
                        .frame(width: 32, height: 32)
                    Text(podcastRequest.stepDescription ?? "Pending")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()

               
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview {
    let podcastRequest = PodcastRequest.sampleData[0]
    PodcastCard(podcastRequest: podcastRequest)
}
