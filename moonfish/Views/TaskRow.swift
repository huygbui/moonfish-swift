//
//  TaskCard.swift
//  moonfish
//
//  Created by Huy Bui on 9/5/25.
//

import SwiftUI


struct TaskRow: View {
    @State var currentTask: PodcastTask
    
    var body: some View {
        HStack(spacing: 16) {
            ProgressView(value: currentTask.currentProgressValue)
                .progressViewStyle(GaugeProgressStyle(strokeWidth: 4))
                .frame(width: 48, height: 48)
                .foregroundStyle(.blue)
            
            
            VStack(alignment: .leading) {
                Text(currentTask.topic)
                    .lineLimit(2, reservesSpace: true)
                HStack {
                    if let currentAction = currentTask.currentAction {
                        Text(
                            TaskAction(rawValue: currentAction)?.description ?? ""
                        )
                    } else {
                        Text(
                            TaskStatus(rawValue: currentTask.status)?.description ?? ""
                        )
                    }
                    
                    Spacer()
                    Text(currentTask.configuration.length.rawValue)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}





#Preview {
    let currentTask = PodcastTask.sampleData[0]
    TaskRow(currentTask: currentTask)
}
