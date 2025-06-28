//
//  PodcastCard.swift
//  moonfish
//
//  Created by Huy Bui on 28/6/25.
//

import SwiftUI

struct PodcastCard: View {
    var podcast: Podcast
    
    var body: some View {
        VStack {
            AsyncImage(url: podcast.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.tertiarySystemFill))
                    .aspectRatio(1, contentMode: .fit)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(podcast.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    PodcastCard(podcast: .preview)
}
