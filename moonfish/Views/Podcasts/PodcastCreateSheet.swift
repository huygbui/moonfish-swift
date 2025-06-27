//
//  PodcastCreateSheet.swift
//  moonfish
//
//  Created by Huy Bui on 27/6/25.
//

import SwiftUI
import PhotosUI

struct PodcastCreateSheet: View {
    @Environment(AuthManager.self) var authManager
    @Environment(EpisodeViewModel.self) var rootModel
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
    @State private var coverImage: Image?
    
    @State private var isSubmitting: Bool = false
    @State private var podcastCoverModel = PodcastCoverModel()
    
    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    EditablePodcastCoverImage(viewModel: podcastCoverModel)
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
            .pickerStyle(.menu)
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
    
    func submit() {
        guard canSubmit else { return }
        
        isSubmitting = true
    }
}

#Preview(traits: .audioPlayerTrait) {
    PodcastCreateSheet()
}
