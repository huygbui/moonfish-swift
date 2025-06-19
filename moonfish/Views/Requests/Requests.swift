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
    @State private var isLoading: Bool = false
    @State var requests = [OngoingPodcastResponse]()
    @State private var phase: CGFloat = -1.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    RequestCardPlaceholder()
                } else {
                    LazyVStack {
                        ForEach(requests) {
                            RequestCard(request: $0)
                        }
                    }
                    .padding(.bottom, {
                        if #available(iOS 26.0, *) {
                            return 0
                        } else {
                            return 128
                        }
                    }())
                }
            }
            .refreshable { await refresh() }
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Requests")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isPresented = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresented) { NewRequestSheet() }
            .task {
                isLoading = true
                defer { isLoading = false }
//                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await refresh()
            }
        }
    }
    
    func refresh() async {
        do {
            requests = try await client.getOngoingPodcasts()
        } catch {
            print("Failed to fetch podcast requests: \(error)")
        }
    }
}

#Preview {
    let client = BackendClient()
    
    Requests()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.backendClient, client)
}
