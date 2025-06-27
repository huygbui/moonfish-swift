//
//  Root.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI
import SwiftData

struct Root: View {
    @Environment(AudioManager.self) private var audioPlayer
    @State private var selectedTab: TabItem = .podcasts
    
    var body: some View {
        if #available(iOS 26.0, *) {
            TabView {
                Tab("Home", systemImage: "house") { HomeRoot() }
                Tab("Podcasts", systemImage: "play.square.stack") { PodcastRoot() }
                Tab(role: .search) { SearchRoot() }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                if let episode = audioPlayer.currentEpisode {
                    PlayerMini(episode: episode)
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
                        .frame(height: audioPlayer.currentEpisode != nil ? 160 : 128)
                        .allowsHitTesting(false)
                        
                        VStack {
                            if let episode = audioPlayer.currentEpisode {
                                PlayerMini(episode: episode)
                                    .background(.regularMaterial, in: .capsule)
                                    .padding(.horizontal, 24)
                                    .brightness(0.1)
                                    .shadow(color: .black.opacity(0.1), radius: 12)
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

#Preview(traits: .audioPlayerTrait) {
    Root()
}
