//
//  PodcastDetail.swift
//  moonfish
//
//  Created by Huy Bui on 24/6/25.
//

import SwiftUI

struct PodcastDetail: View {
    var podcast: Podcast
    var body: some View {
        Text(podcast.title)
    }
}

#Preview {
    PodcastDetail(podcast: .preview)
}
