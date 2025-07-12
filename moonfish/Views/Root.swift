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
                Tab("Home", systemImage: "house") { HomeView() }
                Tab("Podcasts", systemImage: "play.square.stack") { PodcastView() }
                Tab(role: .search) { SearchView() }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                    PlayerMini()
            }
        } else {
            TabView {
                CustomTab("Home", systemImage: "house") { HomeView() }
                CustomTab("Podcasts", systemImage: "play.square.stack") { PodcastView() }
                CustomTab("Search", systemImage: "magnifyingglass") { SearchView() }
            }
            .overlay(alignment: .bottom) {
                CustomPlayerBar
            }
        }
    }
    
    private var CustomPlayerBar: some View {
        PlayerMini()
            .frame(height: 52)
            .background(.bar, in: .rect(cornerRadius: 16))
            .brightness(0.1)
            .shadow(color: .black.opacity(0.25), radius: 16)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [
                        Color(.secondarySystemBackground).opacity(0.0),
                        Color(.secondarySystemBackground),
                        Color(.secondarySystemBackground),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .padding(.bottom, 48)
    }
    
    func CustomTab<Content: View>(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .tabItem {
                Label(title, systemImage: systemImage)
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color(.secondarySystemBackground), for: .tabBar)
    }
}
    

#Preview(traits: .audioPlayerTrait) {
    Root()
}
