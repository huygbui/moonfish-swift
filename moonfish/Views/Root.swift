//
//  Root.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI
import SwiftData

struct Root: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    @State private var searchText: String = ""
    @State private var isPresented: Bool = false

    var body: some View {
        if #available(iOS 26.0, *) {
            TabView {
                Tab("Podcasts", systemImage: "play.square.stack") {
                    Podcasts()
                }
                Tab("Requests", systemImage: "tray") {Requests()}
                Tab(role: .search) {
                    Search()
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                MiniPlayer()
            }
        } else {
            ZStack(alignment: .bottom) {
                TabView {
                    Tab("Podcasts", systemImage: "play.square.stack") {
                        Podcasts()
                    }
                    Tab("Requests", systemImage: "tray") {Requests()}
                    Tab(role: .search) {
                        Search()
                    }
                }
                
                if audioPlayer.currentPodcast != nil {
                    VStack(spacing: 0) {
                        MiniPlayer()
                    }
                    .padding(.bottom, 64)
                }
            }
        }
    }
}

#Preview(traits: .audioPlayer) {
    Root()
}
