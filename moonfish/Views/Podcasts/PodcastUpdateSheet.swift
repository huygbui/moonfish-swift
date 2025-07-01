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
    @Environment(AuthManager.self) var authManager
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
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var newCover: Image?
    @State private var newCoverData: Data?
    @State private var existingCover: Image?
    
    @State private var isProcessingNewCover: Bool = false
    @State private var isLoadingExistingCover: Bool = false
    @State private var isSubmitting: Bool = false
    
    private var hasChanges: Bool {
        title != podcast.title ||
        format != podcast.format ||
        voice1 != podcast.voice1 ||
        name1 != podcast.name1 ||
        voice2 != (podcast.voice2 ?? .female) ||
        name2 != (podcast.name2 ?? "") ||
        description != (podcast.about ?? "") ||
        newCoverData != nil
    }
    
    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        hasChanges &&
        !isSubmitting
    }
    
    // More performant: returns a pre-made image
    private var coverToDisplay: Image? {
        newCover ?? existingCover
    }
    
    private var isCoverLoading: Bool {
        isLoadingExistingCover || isProcessingNewCover
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
                .task { await initFormData() }
                .onChange(of: selectedPhoto) { _, newValue in
                    processSelectedPhoto(item: newValue)
                }
        }
    }
    
    private var content: some View {
        Form {
            Section {
                PodcastCoverImage(image: coverToDisplay, isLoading: isCoverLoading)
                    .overlay(alignment: .center) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Image(systemName: "camera.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.primary, Color(.secondarySystemBackground))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
            }
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
            }
            
            Section("Host 1") {
                TextField("Sam", text: $name1)
                    .textInputAutocapitalization(.words)
                Picker("Voice", selection: $voice1) {
                    ForEach(EpisodeVoice.allCases) { voice in
                        Text(voice.rawValue.localizedCapitalized).tag(voice)
                    }
                }
            }
            
            if format == .conversational {
                Section("Host 2") {
                    TextField("Alex", text: $name2)
                        .textInputAutocapitalization(.words)
                    Picker("Voice", selection: $voice2) {
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
    
    private func initFormData() async {
        title = podcast.title
        format = podcast.format
        voice1 = podcast.voice1
        voice2 = podcast.voice2 ?? .female
        name1 = podcast.name1?.localizedCapitalized ?? ""
        name2 = podcast.name2?.localizedCapitalized ?? ""
        description = podcast.about?.localizedCapitalized ?? ""
        
        if let imageURL = podcast.imageURL {
            isLoadingExistingCover = true
            defer { isLoadingExistingCover = false }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                
                if let uiImage = UIImage(data: data) {
                    self.existingCover = Image(uiImage: uiImage)
                }
            } catch {
                print("Failed to load existing cover image: \(error)")
            }
        }
    }
    
    private func processSelectedPhoto(item: PhotosPickerItem?) {
        guard let item else { return }
        
        Task {
            isProcessingNewCover = true
            defer { isProcessingNewCover = false }
            
            do {
                // Load as Data directly
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    print("Failed to load image data")
                    return
                }
                
                // Validate and compress the image
                guard let uiImage = UIImage(data: data) else {
                    print("Invalid image data")
                    return
                }
                
                // Compress to JPEG with reasonable quality
                if let compressedData = uiImage.jpegData(compressionQuality: 0.8) {
                    newCover = Image(uiImage: uiImage)
                    newCoverData = compressedData
                } else {
                    // Fallback to original data if compression fails
                    newCover = Image(uiImage: uiImage)
                    newCoverData = data
                }
                
            } catch {
                print("Failed to process photo: \(error)")
            }
        }
    }
    
    
    private func submit() {
        guard canSubmit else { return }
        
        isSubmitting = true
        
        Task {
            defer { isSubmitting = false }
            
            if let imageData = newCoverData {
                await rootModel.upload(
                    imageData: imageData,
                    podcastId: podcast.serverId,
                    authManager: authManager
                )
            }
            
            let updateRequest = PodcastUpdateRequest(
                title: title != podcast.title ? title : nil,
                format: format != podcast.format ? format : nil,
                name1: name1 != podcast.name1 ? name1 : nil,
                voice1: voice1 != podcast.voice1 ? voice1 : nil,
                name2: format == .conversational && name2 != (podcast.name2 ?? "") ? name2 : nil,
                voice2: format == .conversational && voice2 != (podcast.voice2 ?? .female) ? voice2 : nil,
                description: description != (podcast.about ?? "") ? description : nil
            )
            
            await rootModel.update(
                podcast,
                from: updateRequest,
                authManager: authManager,
                context: context
            )
            
            dismiss()
        }
    }
}


#Preview(traits: .audioPlayerTrait) {
    PodcastUpdateSheet(podcast: .preview)
}
