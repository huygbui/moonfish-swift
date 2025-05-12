//
//  TaskCard.swift
//  moonfish
//
//  Created by Huy Bui on 9/5/25.
//

import SwiftUI


struct TaskRow: View {
    @State var currentTask: PodcastTask
    @State private var preferredHeight: CGFloat = .zero
    
    var body: some View {
        HStack(spacing: 10) {
            ProgressView(value: currentTask.currentProgressValue)
                .progressViewStyle(GaugeProgressStyle(strokeWidth: 4))
                .padding(16)
                .frame(height: preferredHeight)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.tertiary)
                )
                
           
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
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                preferredHeight = newSize.height
            }
        }
    }
}





#Preview {
    let currentTask = PodcastTask.sampleData[2]
    TaskRow(currentTask: currentTask)
}
