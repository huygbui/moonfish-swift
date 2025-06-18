//
//  RequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct RequestCard: View {
    var request: OngoingPodcastResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card title
                Text(request.topic.localizedCapitalized)
                    .font(.body)
                    .lineLimit(1)
                
                
                // Card subtitle
                HStack {
                    Text(request.createdAt.formatted(Date.RelativeFormatStyle())) +
                    Text(" • ") +
                    Text(request.length.localizedCapitalized) +
                    Text(", ") +
                    Text(request.format.localizedCapitalized) +
                    Text(", ") +
                    Text(request.level.localizedCapitalized)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                ProgressView(value: 0)
                    .progressViewStyle(GaugeProgressStyle())
                    .frame(width: 32, height: 32)
                Text(request.step ?? "Pending")
                    .foregroundStyle(.secondary)
                    .font(.caption)

                Spacer()
                
                RequestCardMenu().foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

#Preview {
    let podcastTask: OngoingPodcastResponse = .init(
        id: 0,
        topic: "Sustainable Urban Gardening",
        length: PodcastLength.medium.rawValue,
        level: PodcastLevel.intermediate.rawValue,
        format: PodcastFormat.conversational.rawValue,
        voice: PodcastVoice.female.rawValue,
        status: RequestStatus.pending.rawValue,
        createdAt: Date(),
        updatedAt: Date(),
    )
    
    RequestCard(request: podcastTask)
}
