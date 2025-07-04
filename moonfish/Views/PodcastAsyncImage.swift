//
//  PodcastAsyncImage.swift
//  moonfish
//
//  Created by Huy Bui on 4/7/25.
//

import SwiftUI

struct PodcastAsyncImage: View {
    var url: URL?
   
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color(.tertiarySystemFill)
        }
    }
}

#Preview {
    PodcastAsyncImage()
}
