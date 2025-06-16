//
//  CustomTabView.swift
//  moonfish
//
//  Created by Huy Bui on 14/6/25.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var body: some View {
        HStack {
            HStack(alignment: .center, spacing: 32) {
                ForEach(TabItem.allCases) { tab in
                    if !tab.isPrimary {
                        Button {
                            selectedTab = tab
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tab.systemImage)
                                    .font(.system(size: 24))
                                    .frame(height: 24)
                                
                                Text(tab.rawValue)
                                    .font(.caption2)
                            }
                            .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 32)
            .frame(height: 64)
            .background(.ultraThinMaterial, in: .capsule)
            
            
            Spacer()
            
            HStack {
                Button {
                    selectedTab = .search
                } label: {
                    VStack {
                        Image(systemName: TabItem.search.systemImage)
                            .font(.title2)
                            .frame(height: 24)
                    }
                    .foregroundStyle(selectedTab == .search ? Color.accentColor : Color.primary)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 64, height: 64)
            .background(.ultraThinMaterial, in: .circle)
        }

    }
}

#Preview {
    @Previewable @State var selectedTab: TabItem = .podcasts
    CustomTabBar(selectedTab: $selectedTab)
}
