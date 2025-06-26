//
//  CreatePodcast.swift
//  moonfish
//
//  Created by Huy Bui on 7/5/25.
//

import SwiftUI

struct CreateSheet: View {
    @Environment(AuthManager.self) var authManager
    @Environment(RequestViewModel.self) var rootModel
    @Environment(\.dismiss) var dismiss
    
    @State private var topic: String = ""
    @State private var length: PodcastLength = .short
    @State private var level: PodcastLevel = .beginner
    @State private var format: PodcastFormat = .narrative
    @State private var voice: PodcastVoice = .female
    @State private var instruction: String = ""
    
    @State private var isSubmitting: Bool = false
    
    private var canSubmit: Bool {
        !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Topic")) {
                    TextField(
                        "What are moonfish?",
                        text: $topic
                    )
                }
                Section(header: Text("Content")) {
                    Picker("Length", selection: $length) {
                        ForEach(PodcastLength.allCases) { length in
                            Text(length.rawValue.localizedCapitalized).tag(length)
                        }
                    }
                    Picker("Level", selection: $level) {
                        ForEach(PodcastLevel.allCases) { level in
                            Text(level.rawValue.localizedCapitalized).tag(level)
                        }
                    }
                }
                Section(header: Text("Delivery")) {
                    Picker("Format", selection: $format) {
                        ForEach(PodcastFormat.allCases) { format in
                            Text(format.rawValue.localizedCapitalized).tag(format)
                        }
                    }
                    Picker("Voice", selection: $voice) {
                        ForEach(PodcastVoice.allCases) { voice in
                            Text(voice.rawValue.localizedCapitalized).tag(voice)
                        }
                    }
                    .disabled(format == .conversational)
                }
                Section(header: Text("Notes")) {
                    TextField(
                        "Focus on the most interesting facts.",
                        text: $instruction,
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
                        Label("Submit", systemImage: "arrow.up")
                    }
                    .disabled(!canSubmit)
                }
            }
        }
    }
    
    func submit() {
        guard canSubmit else { return }
        
        isSubmitting = true

        let config = PodcastConfig(
            topic: topic,
            length: length,
            level: level,
            format: format,
            voice: voice,
            instruction: instruction
        )
        
        Task {
            defer { isSubmitting = false }
            await rootModel.submitRequest(for: config, authManager: authManager)
            dismiss()
        }
    }
}

#Preview {
    CreateSheet()
        .environment(RequestViewModel())
}
