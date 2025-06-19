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
    @State private var selectedTab: TabItem = .podcasts
    
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
                if let podcast = audioPlayer.currentPodcast {
                    let viewModel = PodcastViewModel(podcast: podcast)
                    PlayerMini(viewModel: viewModel)
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                ForEach(TabItem.allCases) { tab in
                    tab.toolbarVisibility(.hidden, for: .tabBar)
                }
            }
            .overlay {
                VStack {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        LinearGradient(
                            colors: [
                                Color(UIColor.secondarySystemBackground).opacity(0),
                                Color(UIColor.secondarySystemBackground),
                                Color(UIColor.secondarySystemBackground),
                                Color(UIColor.secondarySystemBackground),
                                Color(UIColor.secondarySystemBackground)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 160)
                        .allowsHitTesting(false)
                        
                        VStack {
                            if let podcast = audioPlayer.currentPodcast {
                                let viewModel = PodcastViewModel(podcast: podcast)
                                PlayerMini(viewModel: viewModel)
                                    .frame(width: .infinity, height: 48)
                                    .background(.regularMaterial, in: .capsule)
                                    .brightness(0.1)
                                    .shadow(color: .black.opacity(0.1), radius: 12)
                                    .padding(.horizontal, 24)
                            }
                            CustomTabBar(selectedTab: $selectedTab)
                                .compositingGroup()
                                .brightness(0.1)
                                .shadow(color: .black.opacity(0.1), radius: 12)
                                .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 24)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview(traits: .audioPlayer) {
    Root()
}
