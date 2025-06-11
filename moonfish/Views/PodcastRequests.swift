//
//  PodcastTasks.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI
import SwiftData

struct PodcastRequests: View {
    @State private var isPresented: Bool = false
    @Query(sort: \PodcastRequest.createdAt, order: .reverse) private var podcastRequests: [PodcastRequest]
    var requests: [PodcastRequest] {
        return podcastRequests.filter { $0.status != RequestStatus.completed.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(requests) { request in
                        PodcastRequestCard(podcastRequest: request)
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                       isPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresented) { CreateNewPodcast() }
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .navigationTitle("Requests")
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    PodcastRequests()
        .modelContainer(SampleData.shared.modelContainer)
}
