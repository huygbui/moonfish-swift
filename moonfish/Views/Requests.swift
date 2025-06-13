//
//  PodcastTasks.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI
import SwiftData

struct Requests: View {
    @State private var isPresented: Bool = false
    @Query(sort: \PodcastRequest.createdAt, order: .reverse) private var podcastRequests: [PodcastRequest]
    
    private var requests: [PodcastRequest] {
        return podcastRequests.filter { $0.status != RequestStatus.completed.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(requests) {
                        RequestCard(podcastRequest: $0)
                    }
                }
            }
            .sheet(isPresented: $isPresented) { CreateNewPodcast() }
            .navigationTitle("Requests")
            .toolbar {
                ToolbarItem {
                    Button(action: { isPresented = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    Requests()
        .modelContainer(SampleData.shared.modelContainer)
}
