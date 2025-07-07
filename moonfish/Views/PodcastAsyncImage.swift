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
            .resizable()
            .placeholder {
                Color(.tertiarySystemFill)
            }
            .aspectRatio(contentMode: .fill)
            
    }
}

#Preview {
    PodcastAsyncImage()
}
