//
//  ToolbarSettingButton.swift
//  moonfish
//
//  Created by Huy Bui on 9/7/25.
//

import SwiftUI


struct SettingToolbarItem: ToolbarContent {
    let action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button(action: action) {
                Label("Setting", systemImage: "person")
            }
        }
    }
}

struct CreateToolbarItem: ToolbarContent {
    let action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button(action: action) {
                Label("Create", systemImage: "plus")
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("Hello")
            .toolbar {
                SettingToolbarItem(action: {})
                CreateToolbarItem(action: {})
            }
    }
}
