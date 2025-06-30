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
    
    // Photo picker states
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var podcastCoverModel = PodcastCoverModel()
    @State private var coverImage: Image?
    
    @State private var isLoadingExistingImage: Bool = false
    @State private var isSubmitting: Bool = false
    
    // Computed property - automatically recalculates when any state changes
    // This is more efficient than checking on every field change
    private var hasChanges: Bool {
        title != podcast.title ||
        format != podcast.format ||
        voice1 != podcast.voice1 ||
        voice2 != podcast.voice2 ||
        name1 != podcast.name1 ||
        name2 != (podcast.name2 ?? "") ||
        description != (podcast.about ?? "") ||
        podcastCoverModel.hasImage
    }
    
    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        hasChanges &&
        !isSubmitting
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    EditablePodcastCoverImage(
                        existingImage: coverImage,
                        viewModel: podcastCoverModel
                    )
                        .frame(maxWidth: .infinity, alignment: .center)
                }
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
                }
                
                Section("Host 1") {
                    TextField("Sam", text: $name1)
                    Picker("Voice", selection: $voice1) {
                        ForEach(EpisodeVoice.allCases) { voice in
                            Text(voice.rawValue.localizedCapitalized).tag(voice)
                        }
                    }
                }
                
                if format == .conversational {
                    Section("Host 2") {
                        TextField("Alex", text: $name2)
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
            .disabled(isSubmitting)
            .navigationTitle("Edit Podcast")
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
                        if isSubmitting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Label("Save", systemImage: "checkmark")
                        }
                    }
                    .disabled(!canSubmit)
                }
            }
            .onAppear {
                initializeWithPodcastData()
            }
        }
    }
    
    private func initializeWithPodcastData() {
        // Initialize form fields with existing podcast data
        title = podcast.title
        format = podcast.format
        voice1 = podcast.voice1
        voice2 = podcast.voice2 ?? .female
        name1 = podcast.name1 ?? ""
        name2 = podcast.name2 ?? ""
        description = podcast.about ?? ""
        
        if let imageURL = podcast.imageURL {
            loadExistingCoverImage(from: imageURL)
        }
    }
    
    private func loadExistingCoverImage(from url: URL) {
        isLoadingExistingImage = true
        
        Task {
            defer { isLoadingExistingImage = false }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                await MainActor.run {
                    if let uiImage = UIImage(data: data) {
                        coverImage = Image(uiImage: uiImage)
                    }
                }
            } catch {
                await MainActor.run {
                    print("Failed to load existing cover image: \(error)")
                    isLoadingExistingImage = false
                }
            }
        }
    }
    
    func submit() {
        guard canSubmit else { return }
        isSubmitting = true
        
        Task {
            defer { isSubmitting = false }
            
            // Create update request with only changed fields
            let updateRequest = PodcastUpdateRequest(
                title: title != podcast.title ? title : nil,
                format: format != podcast.format ? format : nil,
                name1: name1 != podcast.name1 ? name1 : nil,
                voice1: voice1 != podcast.voice1 ? voice1 : nil,
                name2: format == .conversational && name2 != (podcast.name2 ?? "") ? name2 : nil,
                voice2: format == .conversational && voice2 != podcast.voice2 ? voice2 : nil,
                description: description != (podcast.about ?? "") ? description : nil
            )
            
            // Update the podcast first
            await rootModel.update(
                podcast,
                from: updateRequest,
                authManager: authManager,
                context: context
            )
            
            // Handle image upload separately if user selected a new image
            if let imageData = podcastCoverModel.imageData {
                await rootModel.upload(
                    imageData: imageData,
                    podcastId: podcast.serverId,
                    authManager: authManager
                )
            }
            
            dismiss()
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastUpdateSheet(podcast: .preview)
}
