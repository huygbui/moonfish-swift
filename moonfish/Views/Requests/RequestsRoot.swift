//
//  PodcastTasks.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI

struct RequestsRoot: View {
    @State private var rootModel = RequestViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if rootModel.isLoading {
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
            .refreshable { await rootModel.refresh() }
            .contentMargins(.vertical, 8)
            .safeAreaPadding(.horizontal, 16)
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Requests")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { rootModel.showingCreateSheet = true }) {
                        Label(
                            "Create",
                            systemImage: "plus"
                        )
                    }
                }
            }
            .sheet(isPresented: $rootModel.showingCreateSheet) {
                CreateSheet(rootModel: rootModel)
            }
            .task {
                await rootModel.load()
            }
        }
    }
}

#Preview {
    RequestsRoot()
        .modelContainer(SampleData.shared.modelContainer)
}
