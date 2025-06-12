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
        VStack(alignment: .leading, spacing: 40) {
            // Card header
            VStack(alignment: .leading) {
                // Card title
                Text(podcastRequest.title ?? "Untitled")
                    .font(.body)
                    .lineLimit(1)
                
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
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                if let audioPlayer, podcastRequest.status == RequestStatus.completed.rawValue,
                   let podcast = podcastRequest.completedPodcast {
                    Button(action: { audioPlayer.toggle(podcast) }) {
                        Image(systemName: audioPlayer.isPlaying && audioPlayer.currentPodcast == podcast ? "pause.circle.fill" :"play.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                    Text(Duration.seconds(podcast.duration), format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView(value: podcastRequest.progressValue)
                        .progressViewStyle(GaugeProgressStyle())
                        .frame(width: 36, height: 36)
                    Text(podcastRequest.stepDescription ?? "Pending")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()

                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 32))
    }
}

#Preview {
    let podcastRequest = PodcastRequest.sampleData[0]
    PodcastCard(podcastRequest: podcastRequest)
}
