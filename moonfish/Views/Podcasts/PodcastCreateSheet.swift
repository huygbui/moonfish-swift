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
    @State private var cover: Image?
    @State private var coverData: Data?
    
    @State private var isSubmitting: Bool = false
    @State private var isCoverLoading: Bool = false
    
    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }
    
    var body: some View {
        NavigationStack {
            Form {
                PodcastCoverImage(image: cover, isLoading: isCoverLoading)
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
        }
    }
    
    private func processSelectedPhoto(item: PhotosPickerItem?) {
        guard let item else { return }
        
        Task {
            isCoverLoading = true
            defer { isCoverLoading = false }
            
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else { return }
                
                if let uiImage = UIImage(data: data) {
                    let compressedData = uiImage.jpegData(compressionQuality: 0.8)
                    cover = Image(uiImage: uiImage)
                    coverData = compressedData ?? data
                }
            } catch {
                print("Failed to load image data: \(error)")
            }
        }
    }
    
    
    private func submit() {
        guard canSubmit else { return }
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
                imageData: coverData,
                authManager: authManager,
                context: context
            )
            dismiss()
        }
    }
}


#Preview(traits: .audioPlayerTrait) {
    PodcastCreateSheet()
}
