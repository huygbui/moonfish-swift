//
//  TabItem.swift
//  moonfish
//
//  Created by Huy Bui on 16/6/25.
//

import SwiftUI

enum TabItem:  String, CaseIterable, @MainActor Identifiable, View {
    case home = "Home"
    case podcasts = "Podcasts"
    case search = "Search"
    
    var id: Self { self }
    
    var systemImage: String {
        switch self {
        case .home:
            return "house"
        case .podcasts:
            return "play.square.stack.fill"
        case .search:
            return "magnifyingglass"
        }
    }
    
    var isPrimary: Bool {
        switch self {
        case .search:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        switch self {
        case .home:
            HomeRoot()
        case .podcasts:
            PodcastRoot()
        case .search:
            SearchRoot()
        }
    }
}
