//
//  PodcastList.swift
//  moonfish
//
//  Created by Huy Bui on 12/5/25.
//

import SwiftUI
import SwiftData

struct PodcastList: View {
    var selectedTab: Tab
    @Query private var podcastTasks: [PodcastTask]
   
    init(selectedTab: Tab) {
        self.selectedTab = selectedTab
        _podcastTasks = Query(
            filter: selectedTab.filter,
            sort: \.status,
            order: .reverse
        )
    }
    
    var body: some View {
        ForEach(podcastTasks) { task in
            TaskRow(currentTask: task)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    PodcastList(selectedTab: .completed)
        .modelContainer(SampleData.shared.modelContainer)
}
