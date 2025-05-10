//
//  CustomTabBar.swift
//  moonfish
//
//  Created by Huy Bui on 7/5/25.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabViewEnum
    var body: some View {
        HStack {
            ForEach(TabViewEnum.allCases) { tabView in
                Button {
                    selectedTab = tabView
                    print(selectedTab)
                } label: {
                    Image(systemName: tabView.tabItem.systemImage)
                        .font(.system(size: 24))
                        .padding()
                        .frame(width: 48)
                        .foregroundStyle(.white)
                        .background(.blue, in: .circle)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: TabViewEnum = .library
    CustomTabBar(selectedTab: $selectedTab)
}
