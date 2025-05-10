//
//  DummyDrafts.swift
//  moonfish
//
//  Created by Huy Bui on 9/5/25.
//

import SwiftUI
import SwiftData

struct TaskList: View {
    @Query private var podcastTasks: [PodcastTask]
    @State private var isPresenting: Bool = false
    
    init() {
        let completedStatusValue = TaskStatus.completed.rawValue
        let cancelledStatusValue = TaskStatus.cancelled.rawValue
        _podcastTasks = Query(filter: #Predicate {
            $0.status != completedStatusValue && $0.status != cancelledStatusValue
        })
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(podcastTasks) { task in
                    TaskRow(currentTask: task)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresenting = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $isPresenting) {
                CreatePodcastTask()
            }
        }
    }
}

#Preview {
    TaskList()
        .modelContainer(SampleData.shared.modelContainer)
}
