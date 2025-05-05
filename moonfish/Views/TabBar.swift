//
//  TabBar.swift
//  moonfish
//
//  Created by Huy Bui on 5/5/25.
//

import SwiftUI

enum Tabs: Equatable, Hashable {
    case home
    case library
    case drafts
    case create
    case profile
}

struct TabBar: View {
    @State private var selectedTab: Tabs = .home
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {}
            Tab("Library", systemImage: "waveform", value: .library) {}
            Tab("Create", systemImage: "plus.circle", value: .create) {
               ChatView()
            }
            Tab("Drafts", systemImage: "tray", value: .drafts) {
               ChatListView()
            }
            Tab("Profile", systemImage: "person", value: .profile) {}
        }
    }
}

#Preview {
    TabBar()
}
