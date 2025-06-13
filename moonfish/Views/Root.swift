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
    private var player = AudioPlayer()
    
    var body: some View {
        TabView {
            Tab("Podcasts", systemImage: "play.square.stack") {
                Podcasts(audioPlayer: player)
            }
            Tab("Requests", systemImage: "tray") {Requests()}
            Tab(role: .search) {
                Search(audioPlayer: player)
            }
        }
    }
}

#Preview {
    Root()
        .modelContainer(SampleData.shared.modelContainer)
}
