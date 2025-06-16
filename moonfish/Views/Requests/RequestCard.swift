//
//  RequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct RequestCard: View {
    var podcastRequest: PodcastRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card title
                HStack(spacing: 16) {
                    Text(podcastRequest.title ?? "Untitled")
                        .font(.body)
                        .lineLimit(1)
                }
                
                
                // Card subtitle
                HStack {
                    Text(podcastRequest.createdAt.formatted(Date.RelativeFormatStyle())) +
                    Text(" • ") +
                    Text(podcastRequest.configuration.length.displayName) +
                    Text(", ") +
                    Text(podcastRequest.configuration.format.displayName) +
                    Text(", ") +
                    Text(podcastRequest.configuration.level.displayName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                ProgressView(value: podcastRequest.progressValue)
                    .progressViewStyle(GaugeProgressStyle())
                    .frame(width: 32, height: 32)
                Text(podcastRequest.stepDescription ?? "Pending")
                    .foregroundStyle(.secondary)
                    .font(.caption)

                Spacer()
                
                RequestCardMenu(podcastRequest: podcastRequest).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview {
    let podcastRequest = PodcastRequest.sampleData[0]
    RequestCard(podcastRequest: podcastRequest)
}
