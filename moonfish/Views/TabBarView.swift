//
//  TabBar.swift
//  moonfish
//
//  Created by Huy Bui on 5/5/25.
//

import SwiftUI


struct TabBarView: View {
    @State private var selectedTab: TabViewEnum = .library
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabViewEnum.allCases) { tabView in
                let tabItem = tabView.tabItem
                Tab(
                    tabItem.name,
                    systemImage:tabItem.systemImage,
                    value: tabView) {
                        tabView
                    }
            }
        }
//        .safeAreaInset(edge: .bottom) {
//            CustomTabBar(selectedTab: $selectedTab)
//        }
    }
}


struct TabItem {
    var name: String
    var systemImage: String
}

enum TabViewEnum: Identifiable, CaseIterable, View {
    case library, taskList
    nonisolated var id: Self { self }
    
    var tabItem: TabItem {
        switch self {
        case .library:
                .init(name: "Library", systemImage: "waveform")
        case .taskList:
                .init(name: "Tasks", systemImage: "tray")
        }
    }
    
    var body: some View {
        switch self {
        case .library:
            Library()
        case .taskList:
            TaskList()
        }
    }
    
}


#Preview {
    TabBarView()
        .modelContainer(SampleData.shared.modelContainer)
}
