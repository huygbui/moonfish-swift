//
//  PodcastCreateSheet.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PodcastCreateSheet: View {
    @Environment(PodcastViewModel.self) var rootModel
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var format: EpisodeFormat = .narrative
    @State private var voice1: EpisodeVoice = .male
    @State private var voice2: EpisodeVoice = .female
    @State private var name1: String = ""
    @State private var name2: String = ""
    @State private var description: String = ""
    
    // Photo picker states
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    
    @State private var isImageLoading: Bool = false
    @State private var isSubmitting: Bool = false
    
    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }
    
    var body: some View {
        NavigationStack {
            Form {
                cover
                    .overlay(alignment: .center) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Image(systemName: "camera.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.primary, Color(.secondarySystemBackground))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                
                Section("Title") {
                    TextField(
                        "Name your podcast",
                        text: $title
                    )
                }
                
                Section("Delivery") {
                    Picker("Format", selection: $format) {
                        ForEach(EpisodeFormat.allCases) { format in
                            Text(format.rawValue.localizedCapitalized).tag(format)
                        }
                    }
                    
                    Picker("Host", selection: $voice1) {
                        ForEach(EpisodeVoice.allCases) { voice in
                            Text(voice.rawValue.localizedCapitalized).tag(voice)
                        }
                    }
                    
                    if format == .conversational {
                        Picker("Co-host", selection: $voice2) {
                            ForEach(EpisodeVoice.allCases) { voice in
                                Text(voice.rawValue.localizedCapitalized).tag(voice)
                            }
                        }
                    }
                }
                
                
                Section("Description") {
                    TextField(
                        "Add a brief description of your podcast",
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(4, reservesSpace: true)
                }
            }
            .disabled(isSubmitting)
            .navigationTitle("New Podcast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .disabled(isSubmitting)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: submit) {
                        Label("Submit", systemImage: "checkmark")
                    }
                    .disabled(!canSubmit)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                processPhoto(item: newValue)
            }
        }
    }
    
    @ViewBuilder
    private var cover: some View {
        let size: CGFloat = 128
        let cornerRadius: CGFloat = 16
        
        ZStack {
            if let imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color(.tertiarySystemFill)
            }
            
            if isImageLoading {
                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(cornerRadius)
    }
    
    private func processPhoto(item: PhotosPickerItem?) {
        guard let item else { return }
        isImageLoading = true
        
        Task {
            defer { isImageLoading = false }
            
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                print("Failed to load image data")
                return
            }
                
            imageData = uiImage.jpegData(compressionQuality: 0.8) ?? data
        }
    }
    
    
    private func submit() {
        guard canSubmit else { return }
        // Check creation limit here
//        guard sessionManager.canCreate(.podcast, in: context) else {
//            // Show error
//            return
//        }
        
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            await rootModel.submit(
                PodcastCreateRequest(
                    title: title,
                    format: format,
                    name1: name1,
                    voice1: voice1,
                    name2: name2,
                    voice2: voice2,
                    description: description
                ),
                imageData: imageData,
                context: context
            )
            dismiss()
        }
    }
}


#Preview(traits: .audioPlayerTrait) {
    PodcastCreateSheet()
}
