//
//  PodcastCoverImage.swift
//  moonfish
//
//  Created by Huy Bui on 1/7/25.
//

import SwiftUI

struct PodcastCoverImage: View {
    let image: Image?
    let isLoading: Bool
    
    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color(.secondarySystemFill)
            }
            
            if isLoading {
                ProgressView()
            }
        }
        .frame(width: 128, height: 128)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PodcastCoverImage(image: nil, isLoading: true)
}
