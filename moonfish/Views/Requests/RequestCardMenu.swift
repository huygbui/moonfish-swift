//
//  RequestCardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct RequestCardMenu: View {
//    var podcastTask: PodcastTask
    
    var body: some View {
        Menu {
            Button(role: .destructive) {
            } label: {
                HStack {
                    Image(systemName: "xmark")
                    Text("Cancel")
                }
            }
           
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
                .frame(width: 24, height: 24)
                .background(Color(.tertiarySystemBackground), in: .circle)
        }
    }
}

#Preview {
//    let podcastRequest = PodcastRequest.sampleData[0]
    RequestCardMenu()
}
