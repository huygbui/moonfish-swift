//
//  Root.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI
import SwiftData

struct Root: View {
    @State private var audioPlayer = AudioPlayer()
    @State var selectedTab: Int? = 0
    @State var searchText: String = ""
    @Query private var podcastRequests: [PodcastRequest]
    
    init() {
        let completedStatus = RequestStatus.completed.rawValue
        
        _podcastRequests = Query(
            filter: #Predicate<PodcastRequest> { $0.status == completedStatus },
            sort: \PodcastRequest.createdAt, order: .reverse
        )
    }
    
    var body: some View {
        TabView {
            Tab("Podcasts", systemImage: "ipod") {
                Podcasts()
            }
            Tab("Requests", systemImage: "mail") {
                PodcastRequests()
            }
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
