//
//  PodcastCoverModel.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import SwiftUI
import PhotosUI

@MainActor
@Observable
final class PodcastCoverModel {
    enum ImageState {
        case empty
        case loading(Progress)
        case success(Image, Data)
        case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    private(set) var imageState: ImageState = .empty
    
    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    
    // Add computed property to get image data
    var imageData: Data? {
        if case .success(_, let data) = imageState {
            return data
        }
        return nil
    }
    
    // Add computed property to check if has image
    var hasImage: Bool {
        if case .success = imageState {
            return true
        }
        return false
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: Data.self) { result in
            Task { @MainActor in
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                
                switch result {
                case .success(let data?):
                    #if canImport(UIKit)
                    if let uiImage = UIImage(data: data) {
                        // Compress to JPEG
                        let compressedData = uiImage.jpegData(compressionQuality: 0.8) ?? data
                        let image = Image(uiImage: uiImage)
                        self.imageState = .success(image, compressedData)
                    } else {
                        self.imageState = .failure(TransferError.importFailed)
                    }
                    #else
                    self.imageState = .failure(TransferError.importFailed)
                    #endif
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}
