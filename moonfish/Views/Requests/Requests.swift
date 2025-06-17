//
//  PodcastTasks.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI
import SwiftData

struct Requests: View {
    @Environment(\.backendClient) private var client: BackendClient
    @Query(sort: \PodcastRequest.createdAt, order: .reverse) private var podcastRequests: [PodcastRequest]
    @State private var isPresented: Bool = false
    
    private var requests: [PodcastRequest] {
        return podcastRequests.filter { $0.status != RequestStatus.completed.rawValue }
    }
    
    @State var ongoingTasks = [PodcastCreateResponse]()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(ongoingTasks) {
                        RequestCard(podcastTask: $0)
                    }
                }
            }
            .sheet(isPresented: $isPresented) { NewRequestSheet() }
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
        .task {
            do {
                try await fetchAll()
            } catch {
                print("Failed to fetch")
            }
        }
    }
    
    func fetchAll() async throws {
        ongoingTasks = try await client.getAllPodcasts()
    }
}



#Preview {
    let client = BackendClient()
    
    Requests()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.backendClient, client)
}
