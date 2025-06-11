//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct Podcasts: View {
    @State private var isPresenting: Bool = false
    @State private var audioPlayer = AudioPlayer()

    var body: some View {
        NavigationStack {
            MainContent(audioPlayer: audioPlayer)
            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Image(systemName: "line.horizontal.3")
//                }
//                ToolbarItem {
//                    Image(systemName: "plus")
//                }
//                if #available(iOS 26.0, *) {
//                    ToolbarSpacer()
//                }
               
//                ToolbarItemGroup(placement: .bottomBar) {
//                    Spacer()
//                    Button (action: { isPresenting = true }) {
//                        Image(systemName: "plus")
//                    }
//                }
            }
            .sheet(isPresented: $isPresenting) { CreateNewPodcast() }
            .navigationTitle("Podcasts")
//            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.secondarySystemBackground))
        }
    }
}

struct NavBar: View {
    var body: some View {
        HStack {
            Image(systemName: "line.horizontal.3")
            Spacer()
            Image(systemName: "magnifyingglass")
            Image(systemName: "person.circle")
        }
        .padding(.horizontal)
        .font(.title)
        .foregroundStyle(Color.primary)
    }
}

struct Hero: View {
    var body: some View {
        Text("What do you want to explore today?")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 32)
            .padding(.bottom, 8)
    }
}

struct FilterBar: View {
    @Binding var selectedTab: TabItem
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(TabItem.allCases) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(selectedTab == tab ? Color(.label) : Color(.systemBackground), in: .capsule)
                            .foregroundStyle(selectedTab == tab ? Color(.systemBackground) : Color(.label))
                    }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.vertical, 8)
        .scrollTargetBehavior(.viewAligned)
    }
}

struct MainContent: View {
    var audioPlayer: AudioPlayer
    @Query(sort: \PodcastRequest.createdAt, order: .reverse) private var podcastRequests: [PodcastRequest]
    @State var selectedTab: TabItem = .completed
    @State var scrollID: Int?
    
    var completedRequests: [PodcastRequest] {
        return podcastRequests.filter { $0.status == RequestStatus.completed.rawValue }
    }

    var filteredRequests: [PodcastRequest] {
        switch selectedTab {
        case .all:
            return podcastRequests
        case .completed:
            return podcastRequests.filter { $0.status == RequestStatus.completed.rawValue }
        case .onGoing:
            return podcastRequests.filter { $0.status != RequestStatus.completed.rawValue }
        case .downloaded:
            // Return completed as placeholder for now
            return podcastRequests.filter { $0.status == RequestStatus.completed.rawValue }
        case .favorite:
            // Return completed as placeholder for now
            return podcastRequests.filter { $0.status == RequestStatus.completed.rawValue }

        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
//                Hero()
//                    .id(0)
//                    .visualEffect { content, proxy in
//                        let yOffset = proxy.frame(in: .scrollView).minY
//                        return content.opacity(yOffset < -128 ? 0 : 1)
//                    }
//                FilterBar(selectedTab: $selectedTab)
//                    .id(1)
//                    .visualEffect { content, proxy in
//                        let yOffset = proxy.frame(in: .scrollView).minY
//                        return content
//                            .offset(y: yOffset < 0 ? -yOffset : 0)
//                    }
                
                ForEach(Array(completedRequests.enumerated()), id: \.element) { index, request in
                    PodcastRequestCard(podcastRequest: request, audioPlayer: audioPlayer)
//                        .id(index + 2)
//                        .visualEffect { content, proxy in
//                            let yOffset = proxy.frame(in: .scrollView).minY
//                            let offset = yOffset > 60 ? 0 : yOffset - 60
//                            let scale = max(1.0 - abs(offset) / 1000, 0)
//                            let brightness = min(scale - 1, 0)
//                            
//                            return content
//                                .scaleEffect(scale, anchor: .top)
//                                .brightness(brightness)
//                                .offset(y: -offset)
//                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollID)
        .onChange(of: filteredRequests) { scrollID = 1 }
        .contentMargins(.vertical, 8)
        .safeAreaPadding(.horizontal, 16)
        .safeAreaPadding(.bottom, 512)
        .foregroundStyle(.primary)
    }
}

struct PodcastRequestCard: View {
    var podcastRequest: PodcastRequest
    var audioPlayer: AudioPlayer? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            // Card header
            VStack(alignment: .leading) {
                // Card title
                Text(podcastRequest.title ?? "Untitled")
                    .font(.body)
                    .lineLimit(1)
                
                // Card subtitle
                HStack {
                    Text(podcastRequest.configuration.length.displayName)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                    Text(podcastRequest.configuration.format.displayName)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                    Text(podcastRequest.configuration.level.displayName)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                if let audioPlayer, podcastRequest.status == RequestStatus.completed.rawValue,
                   let podcast = podcastRequest.completedPodcast {
                    Button(action: { audioPlayer.toggle(podcast) }) {
                        Image(systemName: audioPlayer.isPlaying && audioPlayer.currentPodcast == podcast ? "pause.circle.fill" :"play.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                    Text(Duration.seconds(podcast.duration), format: .units(allowed: [.hours, .minutes], width: .abbreviated))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView(value: podcastRequest.progressValue)
                        .progressViewStyle(GaugeProgressStyle())
                        .frame(width: 36, height: 36)
                    Text(podcastRequest.stepDescription ?? "Pending")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()

                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: .rect(cornerRadius: 32))
        .compositingGroup()
    }
}

struct DynamicTabBar: View {
    @Binding var isPresenting: Bool
    let audioPlayer: AudioPlayer

    var body: some View {
        HStack(spacing: 16) {
            // Audio Control
//            HStack(spacing: 16) {
//                Button {
//                    if let podcast = audioPlayer.currentPodcast { audioPlayer.toggle(podcast) }
//                } label: {
//                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
//                        .font(.title2)
//                }
//                Text(audioPlayer.currentPodcast?.title ?? "")
//                Spacer()
//            }
//            .padding(32)
//            .frame(height: 64)
//            .background(Color.primary, in: .capsule)
            
            // Create Podcast Button
            Button(action: { isPresenting = true }) {
                if #available(iOS 26.0, *) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .frame(width: 64, height: 64)
                        .glassEffect(in: .circle)
                } else {
                    Image(systemName: "plus")
                        .font(.title2)
                        .frame(width: 64, height: 64)
                        .foregroundStyle(Color(.secondarySystemBackground))
                        .background(.primary, in: .circle)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .ignoresSafeArea()
        .compositingGroup()
    }
}

#Preview {
    Podcasts()
        .modelContainer(SampleData.shared.modelContainer)
}
