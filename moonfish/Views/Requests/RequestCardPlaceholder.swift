//
//  RequestCardPlaceholder.swift
//  moonfish
//
//  Created by Huy Bui on 18/6/25.
//

import SwiftUI

struct RequestCardPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Card header
            VStack(alignment: .leading, spacing: 0) {
                // Card title placeholder
                Text("Placeholder Title")
                    .font(.body)
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
                
                // Card subtitle placeholder
                Text("2 hours ago • Medium, Conversational, Intermediate")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .redacted(reason: .placeholder)
            }
            
            // Card footer
            HStack {
                // Progress gauge placeholder
                ProgressView(value: 0)
                    .progressViewStyle(GaugeProgressStyle())
                    .frame(width: 32, height: 32)

                Text("Placeholder Step")
                    .font(.caption)
                    .redacted(reason: .placeholder)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 16))
        .shimmer()
    }
}

#Preview {
   RequestCardPlaceholder()
}
