//
//  PodcastTask.swift
//  moonfish
//
//  Created by Huy Bui on 13/5/25.
//

import SwiftUI
import SwiftData

struct Home: View {
    @State private var isPresenting: Bool = false
    @State private var audioPlayer = AudioPlayer()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    NavBar()
                    MainContent(audioPlayer: audioPlayer)
                }

                DynamicTabBar(isPresenting: $isPresenting, audioPlayer: audioPlayer)
            }
            .fullScreenCover(isPresented: $isPresenting) { CreateNewPodcast() }
            .background(Color(.secondarySystemBackground).gradient)
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
        .foregroundStyle(Color.secondary)
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
    @Binding var selectedTab: Tab
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(Tab.allCases) { tab in
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
                    .compositingGroup()
                    .shadow(radius: 2, x: 0, y:2)
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
    @Query(sort: \PodcastRequest.createdDate, order: .reverse) private var podcastRequests: [PodcastRequest]
    @State var selectedTab: Tab = .all
    @State var scrollID: Int?

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
                Hero()
                    .id(0)
                    .visualEffect { content, proxy in
                        let yOffset = proxy.frame(in: .scrollView).minY
                        var opacity: CGFloat = 1.0
                        
                        if yOffset < 0 {
                            let fadeDistance: CGFloat = 56.0
                            let currentScroll = abs(yOffset)
                            let scrollProgress = min(1.0, currentScroll / fadeDistance)
                            opacity = 1.0 - pow(scrollProgress, 2.0)
                            opacity = max(0.0, min(1.0, opacity))
                        }
                        
                        return content.opacity(opacity)
                    }
                FilterBar(selectedTab: $selectedTab)
                    .id(1)
                    .visualEffect { content, proxy in
                        let yOffset = proxy.frame(in: .scrollView).minY
                        return content
                            .offset(y: yOffset < 0 ? -yOffset : 0)
                    }
                
                ForEach(Array(filteredRequests.enumerated()), id: \.element) { index, request in
                    PodcastRequestCard(podcastRequest: request, audioPlayer: audioPlayer)
                        .id(index + 2)
                        .visualEffect { content, proxy in
                            let yOffset = proxy.frame(in: .scrollView).minY
                            let offset = yOffset > 60 ? 0 : yOffset - 60
                            let scale = max(1.0 - abs(offset) / 1000, 0)
                            let brightness = min(scale - 1, 0)
                            
                            return content
                                .scaleEffect(scale, anchor: .top)
                                .brightness(brightness)
                                .offset(y: -offset)
                        }
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
    let audioPlayer: AudioPlayer

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
                    Text(podcastRequest.configuration.length.rawValue)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                    Text(podcastRequest.configuration.format.rawValue)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                    Text(podcastRequest.configuration.level.rawValue)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            // Card footer
            HStack {
                if podcastRequest.status == RequestStatus.completed.rawValue,
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
        .shadow(radius: 4, x:0, y:4)
    }
}

struct DynamicTabBar: View {
    @Binding var isPresenting: Bool
    let audioPlayer: AudioPlayer

    var body: some View {
        HStack(spacing: 16) {
            // Audio Control
            HStack(spacing: 16) {
                Button {
                    if let podcast = audioPlayer.currentPodcast { audioPlayer.toggle(podcast) }
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                Text(audioPlayer.currentPodcast?.title ?? "")
                Spacer()
            }
            .padding(32)
            .frame(height: 64)
            .background(Color.primary, in: .capsule)
            
            // Create Podcast Button
            Button(action: { isPresenting = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .frame(width: 64, height: 64)
                    .background(Color.primary, in: .circle)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .foregroundStyle(Color(.systemBackground))
        .ignoresSafeArea()
        .compositingGroup()
        .shadow(radius: 4, x:0, y:4)
    }
}

#Preview {
    Home()
        .modelContainer(SampleData.shared.modelContainer)
}
