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
        VStack(alignment: .leading) {
            AsyncImage(url: podcast.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(.tertiarySystemFill)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .aspectRatio(1, contentMode: .fit)


            Text(podcast.title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    ScrollView {
        LazyVGrid(columns: columns) {
            ForEach(1..<5) { _ in
                PodcastCard(podcast: .preview)
            }
        }
        .padding(.horizontal)
    }
            
}
