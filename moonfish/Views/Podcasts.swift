//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct Podcasts: View {
    @State private var isPresented: Bool = false
    @State private var audioPlayer = AudioPlayer()
    @Query(sort: \PodcastRequest.createdAt, order: .reverse) private var podcastRequests: [PodcastRequest]
    
    private var requests: [PodcastRequest] {
        return podcastRequests.filter { $0.status == RequestStatus.completed.rawValue }
    }
    
    
    var body: some View {
        let newRequests = requests.filter { $0.completedPodcast?.wasPlayed == false}
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Newly Added").font(.headline)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(newRequests) {
                                    if let podcast = $0.completedPodcast {
                                     PodcastCardHighlight(
                                        podcast: podcast,
                                        audioPlayer: audioPlayer
                                    )
                                    .frame(width: 256, height: 256)   
                                    }
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Past Tracks").font(.headline)
                        VStack(spacing: 8) {
                            ForEach(requests){
                                if let podcast = $0.completedPodcast {
                                    PodcastCard(
                                        podcast: podcast,
                                        audioPlayer: audioPlayer
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Podcasts")
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .toolbar {
                ToolbarItem {
                    Button(action: {  }) {
                        Image(systemName: "person")
                    }
                }
                
               
            }
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
        }
    }
}



#Preview {
    Podcasts()
        .modelContainer(SampleData.shared.modelContainer)
}
