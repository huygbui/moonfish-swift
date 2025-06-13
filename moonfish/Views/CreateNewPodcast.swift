//
//  CreatePodcast.swift
//  moonfish
//
//  Created by Huy Bui on 7/5/25.
//

import SwiftUI

struct CreateNewPodcast: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.backendClient) private var client
    @Environment(\.dismiss) var dismiss
    @State private var topic: String = ""
    @State private var selectedLength: PodcastLength = .short
    @State private var selectedFormat: PodcastFormat = .narrative
    @State private var selectedLevel: PodcastLevel = .beginner
    @State private var selectedVoice: PodcastVoice = .female
    @State private var instruction: String = ""
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
                    Picker("Length", selection: $selectedLength) {
                        ForEach(PodcastLength.allCases) { length in
                            Text(length.rawValue.localizedCapitalized).tag(length)
                        }
                    }
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(PodcastLevel.allCases) { level in
                            Text(level.rawValue.localizedCapitalized).tag(level)
                        }
                    }
                }
                Section(header: Text("Delivery")) {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(PodcastFormat.allCases) { format in
                            Text(format.rawValue.localizedCapitalized).tag(format)
                        }
                    }
                    Picker("Voice", selection: $selectedVoice) {
                        ForEach(PodcastVoice.allCases) { voice in
                            Text(voice.rawValue.localizedCapitalized).tag(voice)
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
            .pickerStyle(.menu)
            .navigationTitle("New Podcast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                       dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await submit()
                        }
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                }
            }
        }
    }
}
 
extension CreateNewPodcast {
    func submit() async {
        let configuration = PodcastConfiguration(
            topic: topic,
            length: selectedLength,
            level: selectedLevel,
            format: selectedFormat,
            voice: selectedVoice,
            instruction: instruction
        )
        
        do {
            let requestResponse = try await client.createPodcast(configuration: configuration)
            let podcastRequest = PodcastRequest(
                id: requestResponse.id,
                configuration: configuration,
                createdAt: requestResponse.createdAt,
                updatedAt: requestResponse.updatedAt
            )
            
            modelContext.insert(podcastRequest)
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        dismiss()
    }
}

#Preview {
    CreateNewPodcast()
}
