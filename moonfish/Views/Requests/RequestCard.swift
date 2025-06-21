//
//  RequestCard.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct RequestCard: View {
    var request: PodcastRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card title
                Text(request.topic.localizedCapitalized)
                    .font(.body)
                    .lineLimit(1)
                
                
                // Card subtitle
                Text("""
                    \(request.createdAt.relative) • \
                    \(request.length.localizedCapitalized), \
                    \(request.format.localizedCapitalized), \
                    \(request.level.localizedCapitalized)
                    """
                )
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                ProgressView(value: 0)
                    .progressViewStyle(GaugeProgressStyle())
                    .frame(width: 32, height: 32)
                Text(request.formattedStep)
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
    RequestCard(request: .preview)
}
