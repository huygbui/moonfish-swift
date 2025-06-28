//
//  PodcastCoverImage.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import SwiftUI
import PhotosUI

struct PodcastCoverImage: View {
    let imageState: PodcastCoverModel.ImageState
    
    var body: some View {
        switch imageState {
        case .success(let image, _):
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .loading, .empty, .failure:
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemFill))
        }
    }
}

struct RectangleCoverImage: View {
    let imageState: PodcastCoverModel.ImageState
    
    var body: some View {
        PodcastCoverImage(imageState: imageState)
            .frame(width: 128, height: 128)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EditablePodcastCoverImage: View {
    @Bindable var viewModel: PodcastCoverModel
    
    var body: some View {
        RectangleCoverImage(imageState: viewModel.imageState)
            .overlay(alignment: .center) {
                PhotosPicker(selection: $viewModel.imageSelection,
                             matching: .images,
                             photoLibrary: .shared())
                {
                    Image(systemName: "camera.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
    }
}


#Preview {
    @Previewable @State var viewModel = PodcastCoverModel()
    ZStack {
        Color(.secondarySystemBackground)
        
        EditablePodcastCoverImage(viewModel: viewModel)
    }
    .ignoresSafeArea()
}
