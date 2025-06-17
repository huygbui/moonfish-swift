//
//  PodcastTasks.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI

struct Requests: View {
    @Environment(\.backendClient) private var client: BackendClient
    @State private var isPresented: Bool = false
    @State var requests = [OngoingPodcastResponse]()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(requests) {
                        RequestCard(request: $0)
                    }
                }
            }
            .refreshable { await refresh() }
            .navigationTitle("Requests")
            .toolbar {
                ToolbarItem {
                    Button(action: { isPresented = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresented) { NewRequestSheet() }
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .foregroundStyle(.primary)
            .background(Color(.secondarySystemBackground))
        }
        .task {
            await refresh()
        }
    }
    
    func refresh() async {
        do {
            requests = try await client.getOngoingPodcasts()
        } catch {
            print("Failed to fetch: \(error)")
        }
    }
}

#Preview {
    let client = BackendClient()
    
    Requests()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.backendClient, client)
}
