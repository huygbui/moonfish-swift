//
//  Root.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI
import SwiftData

struct Root: View {
    @State private var searchText: String = ""
    
    var body: some View {
        TabView {
            Tab("Podcasts", systemImage: "play.square.stack") {Podcasts()}
            Tab("Requests", systemImage: "tray") {PodcastRequests()}
            Tab(role: .search) {
                NavigationStack {
                }
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    Root()
        .modelContainer(SampleData.shared.modelContainer)
}
