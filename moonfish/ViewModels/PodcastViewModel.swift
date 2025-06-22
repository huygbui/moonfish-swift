//
//  PodcastViewModel.swift
//  moonfish
//
//  Created by Huy Bui on 18/6/25.
//

import SwiftUI
import SwiftData

@MainActor
@Observable
class PodcastViewModel {
    let playbackRateOptions: [Double] = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    let timerOptions: [Double] = [0, 5, 10, 15, -1]
    
    private let client = BackendClient()
    private var downloads: [Int:Download] = [:]

    func refreshAudioURL(_ podcast: Podcast, modelContext: ModelContext) async {
        if podcast.expiresAt == nil || Date() > podcast.expiresAt! {
            do {
                let audio = try await client.getPodcastAudio(id: podcast.taskId)
                podcast.url = audio.url
                podcast.expiresAt = audio.expiresAt
                try modelContext.save()
            } catch {
                print("Failed to fetch podcast audio: \(error)")
            }
        }
    }
    
    func refresh(_ context: ModelContext) async {
        do {
            let serverPodcasts = try await client.getCompletedPodcasts()
            for serverPodcast in serverPodcasts {
                if let podcast = Podcast(from: serverPodcast) {
                    context.insert(podcast)
                }
            }
            try context.save()
        } catch {
            print("Failed to fetch podcasts: \(error)")
        }
    }
    
    func delete(_ podcast: Podcast, context: ModelContext) async {
        do {
            try await client.deletePodcast(id: podcast.taskId)
            context.delete(podcast)
        } catch {
            print("Failed to delete podcast: \(error)")
        }
    }
    
    func toggleFavorite(_ podcast: Podcast) {
        podcast.isFavorite.toggle()
    }
    
    func download(_ podcast: Podcast) async throws {
        guard downloads[podcast.taskId] == nil,
              podcast.downloadState == .idle || podcast.downloadState == .canceled
        else { return }
        
        let request = try client.createRequest(for: "podcasts/\(podcast.taskId)/download")

        let download = if podcast.downloadState == .canceled,
                          let resumeData = podcast.resumeData {
            Download(resumeData: resumeData)
        } else {
            Download(request: request)
        }
        
        downloads[podcast.taskId] = download
        download.start()
        podcast.downloadState = .dowloading
        for await event in download.events {
            process(event, for: podcast)
        }
        
        downloads[podcast.taskId] = nil
    }
    
    func cancelDownload(for podcast: Podcast) {
        downloads[podcast.taskId]?.cancel()
        podcast.downloadState = .idle
    }
    
    func process(_ event: Download.Event, for podcast: Podcast) {
        switch event {
        case let .progress(current, total):
            podcast.update(currentBytes: current, totalBytes: total)
        case let .completed(url):
            saveFile(for: podcast, at: url)
            podcast.downloadState = .completed
        case let .canceled(data):
            if let data {
                podcast.downloadState = .canceled
                podcast.resumeData = data
            } else {
                podcast.downloadState = .idle
            }
        }
    }
    
    func saveFile(for podcast: Podcast, at url: URL) {
        let filemanager = FileManager.default
        do {
            try filemanager.moveItem(at: url, to: podcast.fileURL)
        } catch {
            print("Failed to save podcast \(podcast.id): \(error)")
        }
    }
}
