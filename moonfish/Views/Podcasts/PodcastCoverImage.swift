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
    let existingImage: Image?
    
    var body: some View {
        switch imageState {
        case .success(let image, _):
            // Show new image selected by user
            image
                .resizable()
                .scaledToFill()
        case .loading, .empty, .failure:
            // Show existing image or placeholder
            if let existingImage = existingImage {
                existingImage
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemFill))
            }
        }
    }
}

struct RectangleCoverImage: View {
    let imageState: PodcastCoverModel.ImageState
    let existingImage: Image?
    
    var body: some View {
        PodcastCoverImage(
            imageState: imageState,
            existingImage: existingImage
        )
        .frame(width: 128, height: 128)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EditablePodcastCoverImage: View {
    let existingImage: Image?
    @Bindable var viewModel: PodcastCoverModel
    
    var body: some View {
        RectangleCoverImage(
            imageState: viewModel.imageState,
            existingImage: existingImage
        )
        .overlay(alignment: .center) {
            PhotosPicker(selection: $viewModel.imageSelection,
                         matching: .images,
                         photoLibrary: .shared())
            {
                Image(systemName: "camera.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    @Previewable @State var viewModel = PodcastCoverModel()
    ZStack {
        Color(.secondarySystemBackground)
        
        EditablePodcastCoverImage(
            existingImage: nil,
            viewModel: viewModel
        )
    }
    .ignoresSafeArea()
}
