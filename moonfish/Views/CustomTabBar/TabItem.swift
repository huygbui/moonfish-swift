//
//  TabItem.swift
//  moonfish
//
//  Created by Huy Bui on 16/6/25.
//

import SwiftUI

enum TabItem:  String, CaseIterable, @MainActor Identifiable, View {
    case podcasts = "Podcasts"
    case requests = "Requests"
    case search = "Search"
    
    var id: Self { self }
    
    var systemImage: String {
        switch self {
        case .podcasts:
            return "play.square.stack.fill"
        case .requests:
            return "tray.fill"
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
        case .podcasts:
            Podcasts()
        case .requests:
            Requests()
        case .search:
            Search()
        }
    }
}
