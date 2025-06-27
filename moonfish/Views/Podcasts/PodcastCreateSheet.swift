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
    @Environment(PodcastViewModel.self) var rootModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var format: PodcastFormat = .narrative
    @State private var voice1: PodcastVoice = .male
    @State private var voice2: PodcastVoice = .female
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
                Section("Title") {
                    TextField(
                        "Give your podcast a title",
                        text: $title
                    )
                }
                    
                Section("Description") {
                    TextField(
                        "Add a brief description of your podcast",
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(4, reservesSpace: true)
                }
                
                Section("Delivery") {
                    Picker("Format", selection: $format) {
                        ForEach(PodcastFormat.allCases) { format in
                            Text(format.rawValue.localizedCapitalized).tag(format)
                        }
                    }
                    
                    if format == .conversational {
                        Picker("Host 1", selection: $voice1) {
                            ForEach(PodcastVoice.allCases) { voice in
                                Text(voice.rawValue.localizedCapitalized).tag(voice)
                            }
                        }
                        
                        Picker("Host 2", selection: $voice2) {
                            ForEach(PodcastVoice.allCases) { voice in
                                Text(voice.rawValue.localizedCapitalized).tag(voice)
                            }
                        }
                    } else {
                        Picker("Host", selection: $voice1) {
                            ForEach(PodcastVoice.allCases) { voice in
                                Text(voice.rawValue.localizedCapitalized).tag(voice)
                            }
                        }
                    }
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
