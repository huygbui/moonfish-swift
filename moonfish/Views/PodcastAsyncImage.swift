//
//  PodcastAsyncImage.swift
//  moonfish
//
//  Created by Huy Bui on 4/7/25.
//

import SwiftUI
import Kingfisher

struct PodcastAsyncImage: View {
    var url: URL?
   
    var body: some View {
        KFImage(url)
            .placeholder { Color(.tertiarySystemFill) }
            .downsampling(size: CGSize(width: 256, height: 256))
            .scaleFactor(UIScreen.main.scale)
            .cacheOriginalImage(true)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

#Preview {
    PodcastAsyncImage()
}
