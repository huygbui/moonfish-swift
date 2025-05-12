//
//  DummyDrafts.swift
//  moonfish
//
//  Created by Huy Bui on 9/5/25.
//

import SwiftUI
import SwiftData

struct Home: View {
    @State private var isPresenting: Bool = false
    @State private var selectedTab: Tab = .completed
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Your Podcasts")
                    .font(.largeTitle.bold())
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                Picker("Select Tab", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                
                PodcastList(selectedTab: selectedTab)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isPresenting = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $isPresenting) {
                CreatePodcastTask()
            }
        }
    }
}

#Preview {
    Home()
        .modelContainer(SampleData.shared.modelContainer)
}
