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
    
    var body: some View {
        if #available(iOS 26.0, *) {
            TabView {
                Tab("Home", systemImage: "house") { HomeRoot() }
                Tab("Podcasts", systemImage: "play.square.stack") { PodcastRoot() }
                Tab(role: .search) { SearchRoot() }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                if audioPlayer.currentEpisode != nil {
                    PlayerMini()
                }
            }
        } else {
            TabView {
                CustomTab("Home", systemImage: "house") { HomeRoot() }
                CustomTab("Podcasts", systemImage: "play.square.stack") { PodcastRoot() }
                CustomTab("Search", systemImage: "magnifyingglass") { SearchRoot() }
            }
            .safeAreaInset(edge: .bottom) {
                if audioPlayer.currentEpisode != nil {
                    PlayerBar()
                }
            }
        }
    }
    
    @ViewBuilder
    func PlayerBar() -> some View {
        ZStack(alignment: .bottom) {
            PlayerMini()
                .frame(height: 52)
            
            Divider()
        }
        .background(.thickMaterial)
        .padding(.bottom, 49)
    }
        
    @ViewBuilder
    func CustomTab<Content: View>(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(.bottom, audioPlayer.currentEpisode != nil ? 52 : 0)
            .tabItem {
                Label(title, systemImage: systemImage)
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.thickMaterial, for: .tabBar)
    }
}

#Preview(traits: .audioPlayerTrait) {
    Root()
}
