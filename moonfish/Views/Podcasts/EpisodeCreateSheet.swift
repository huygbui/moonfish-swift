//
//  CreatePodcast.swift
//  moonfish
//
//  Created by Huy Bui on 7/5/25.
//

import SwiftUI

struct EpisodeCreateSheet: View {
    var podcast: Podcast
    @Environment(AuthManager.self) var authManager
    @Environment(PodcastViewModel.self) var rootModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context

    @State private var topic: String = ""
    @State private var length: EpisodeLength = .short
    @State private var level: EpisodeLevel = .beginner
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
                        ForEach(EpisodeLength.allCases) { length in
                            Text(length.rawValue.localizedCapitalized).tag(length)
                        }
                    }
                    Picker("Level", selection: $level) {
                        ForEach(EpisodeLevel.allCases) { level in
                            Text(level.rawValue.localizedCapitalized).tag(level)
                        }
                    }
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

        Task {
            defer { isSubmitting = false }
            await rootModel.submit(
                EpisodeCreateRequest(
                    topic: topic,
                    length: length,
                    level: level,
                    instruction: instruction
                ),
                podcast: podcast,
                authManager: authManager,
                context: context
            )
            dismiss()
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    EpisodeCreateSheet(podcast: .preview)
}
