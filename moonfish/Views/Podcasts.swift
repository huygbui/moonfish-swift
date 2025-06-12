//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct Podcasts: View {
    @State private var isPresenting: Bool = false
    @State private var audioPlayer = AudioPlayer()
    @Query(sort: \PodcastRequest.createdAt, order: .reverse) private var podcastRequests: [PodcastRequest]
    
    private var requests: [PodcastRequest] {
        return podcastRequests.filter { $0.status == RequestStatus.completed.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(requests){
                        PodcastCard(
                            podcastRequest: $0,
                            audioPlayer: audioPlayer
                        )
                    }
                }
            }
            .navigationTitle("Podcasts")
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
        }
    }
}



#Preview {
    Podcasts()
        .modelContainer(SampleData.shared.modelContainer)
}
