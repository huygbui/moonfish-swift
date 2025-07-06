//
//  PodcastHighlight.swift
//  moonfish
//
//  Created by Huy Bui on 1/7/25.
//

import SwiftUI

struct PodcastHighlight: View {
    let podcast: Podcast
    let size: CGFloat = 160
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: podcast.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(.tertiarySystemFill)
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .aspectRatio(1, contentMode: .fit)
            
            Text(podcast.title)
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(podcast.format.rawValue.localizedCapitalized)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(alignment: .top, spacing: 16) {
            ForEach(1..<5) { _ in
                PodcastHighlight(podcast: .preview)
            }
        }
    }
    .contentMargins(.horizontal, 16)
}
