//
//  PodcastUpdateSheet.swift
//  moonfish
//
//  Created by Huy Bui on 28/6/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PodcastUpdateSheet: View {
    var podcast: Podcast
    @Environment(SessionManager.self) var sessionManager
    @Environment(PodcastViewModel.self) var rootModel
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var format: EpisodeFormat
    @State private var voice1: EpisodeVoice
    @State private var voice2: EpisodeVoice
    @State private var description: String
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?

    @State private var isImageLoading: Bool = false
    @State private var isSubmitting: Bool = false

    init(podcast: Podcast) {
        self.podcast = podcast
        _title = State(initialValue: podcast.title)
        _format = State(initialValue: podcast.format)
        _voice1 = State(initialValue: podcast.voice1)
        _voice2 = State(initialValue: podcast.voice2 ?? .female)
        _description = State(initialValue: podcast.about ?? "")
    }
    
    private var hasChanges: Bool {
        let titleChanged = title.trimmingCharacters(in: .whitespacesAndNewlines) != podcast.title
        let formatChanged = format != podcast.format
        let voice1Changed = voice1 != podcast.voice1
        let voice2Changed = voice2 != (podcast.voice2 ?? .female)
        let descriptionChanged = description.trimmingCharacters(in: .whitespacesAndNewlines) != (podcast.about ?? "")
        let imageChanged = imageData != nil
        
        return titleChanged || formatChanged || voice1Changed || voice2Changed || descriptionChanged || imageChanged
    }
    
    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting &&
        hasChanges
    }
   
    var body: some View {
        NavigationStack {
            content
                .disabled(isSubmitting)
                .navigationTitle("Edit Podcast")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    dismissButton
                    submitButton
                }
                .onChange(of: selectedPhoto) { _, newValue in
                    processPhoto(item: newValue)
                }
        }
    }
    
    private var content: some View {
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
                TextField("Name your podcast", text: $title)
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
                PodcastAsyncImage(url: podcast.imageURL)
            }
            
            if isImageLoading {
                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(cornerRadius)
    }
    
    private var dismissButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: { dismiss() }) {
                Label("Cancel", systemImage: "xmark")
            }
            .disabled(isSubmitting)
        }
    }
    
    private var submitButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: submit) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Label("Save", systemImage: "checkmark")
                }
            }
            .disabled(!canSubmit)
        }
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
        isSubmitting = true
        
        Task {
            defer { isSubmitting = false }
            
            let updateRequest = PodcastUpdateRequest(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                format: format,
                voice1: voice1,
                voice2: format == .conversational ? voice2 : nil,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            await rootModel.update(
                podcast,
                updateRequest: updateRequest,
                imageData: imageData,
                sessionManager: sessionManager,
                context: context
            )
            
            dismiss()
        }
    }
}


#Preview(traits: .audioPlayerTrait) {
    PodcastUpdateSheet(podcast: .preview)
}
