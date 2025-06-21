//
//  CreatePodcast.swift
//  moonfish
//
//  Created by Huy Bui on 7/5/25.
//

import SwiftUI

struct CreateSheet: View {
    @Bindable var rootModel: RequestViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var topic: String = ""
    @State var length: PodcastLength = .short
    @State var level: PodcastLevel = .beginner
    @State var format: PodcastFormat = .narrative
    @State var voice: PodcastVoice = .female
    @State var instruction: String = ""
    
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
                    Button(action: submit) {
                        Label(
                            "Submit Request",
                            systemImage: "arrow.up"
                        )
                    }
                }
            }
        }
    }
    
    func submit() {
        Task {
            let config = PodcastConfig(
                topic: topic,
                length: length,
                level: level,
                format: format,
                voice: voice,
                instruction: instruction
            )
            
            await rootModel.submitRequest(for: config)
            
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var rootModel = RequestViewModel()
    CreateSheet(rootModel: rootModel)
}
