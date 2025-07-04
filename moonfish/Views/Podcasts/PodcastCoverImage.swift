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
    let size: CGFloat = 128
    let cornerRadius: CGFloat = 16
    
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
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    PodcastCoverImage(image: nil, isLoading: true)
}
