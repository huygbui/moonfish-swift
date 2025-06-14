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
    @State private var isPresented: Bool = false
    private var player = AudioPlayer()
    
    var body: some View {
        if #available(iOS 26.0, *) {
            TabView {
                Tab("Podcasts", systemImage: "play.square.stack") {
                    Podcasts(audioPlayer: player)
                }
                Tab("Requests", systemImage: "tray") {Requests()}
                Tab(role: .search) {
                    Search(audioPlayer: player)
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                MiniPlayer(audioPlayer: player)
            }
        } else {
            TabView {
                Tab("Podcasts", systemImage: "play.square.stack") {
                    Podcasts(audioPlayer: player)
                }
                Tab("Requests", systemImage: "tray") {Requests()}
                Tab(role: .search) {
                    Search(audioPlayer: player)
                }
            }
            
            if player.currentPodcast != nil {
                VStack(spacing: 0) {
                    Spacer()
                    MiniPlayer(audioPlayer: player)
                }
                .ignoresSafeArea(.keyboard)
            }
//           CustomTabView()
        }
    }
}

#Preview {
    Root()
        .modelContainer(SampleData.shared.modelContainer)
}
