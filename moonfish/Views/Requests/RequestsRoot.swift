//
//  PodcastTasks.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI

struct RequestsRoot: View {
    @Environment(RequestViewModel.self) private var rootModel
    @Environment(AuthManager.self) private var authManager
    @State private var showingCreateSheet: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    RequestCardPlaceholder()
                } else {
                    LazyVStack {
                        ForEach(rootModel.requests) {
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
            .refreshable { await rootModel.refresh(authManager: authManager) }
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Requests")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingCreateSheet = true }) {
                        Label("Create", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                EpisodeCreate()
            }
            .task {
                isLoading = true
                defer { isLoading = false }
//                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await rootModel.refresh(authManager: authManager)
            }
        }
    }
}

#Preview(traits: .audioPlayerTrait) {
    RequestsRoot()
}
