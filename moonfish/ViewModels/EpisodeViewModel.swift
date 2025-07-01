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
class EpisodeViewModel {
    let playbackRateOptions: [Double] = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    let timerOptions: [Double] = [0, 5, 10, 15, -1]
    
    private let client = BackendClient()
    private var downloads: [Int:Download] = [:]
    
    func refreshAudioURL(_ episode: Episode, modelContext: ModelContext, authManager: AuthManager) async {
        guard let token = authManager.token else { return }

        if episode.expiresAt == nil || Date() > episode.expiresAt! {
            do {
                let audio = try await client.getEpisodeAudio(id: episode.serverId, authToken: token)
                episode.audioURL = audio.url
                episode.expiresAt = audio.expiresAt
                try modelContext.save()
            } catch {
                print("Failed to fetch podcast audio: \(error)")
            }
        }
    }
    
    func cancel(_ episode: Episode, authManager: AuthManager, context: ModelContext) async {
        guard let token = authManager.token else { return }
       
        do {
            try await client.cancelOngoingEpisode(id: episode.serverId, authToken: token)
            episode.status = .cancelled
            try context.save()
        } catch {
            print("Failed to cancel episode: \(error)")
        }
    }
    
    func delete(_ episode: Episode, context: ModelContext, authManager: AuthManager) async {
        guard let token = authManager.token else { return }
        
        do {
            try await client.deleteEpisode(id: episode.serverId, authToken: token)
            try? FileManager.default.removeItem(at: episode.fileURL)
            context.delete(episode)
            try context.save()
        } catch {
            print("Failed to delete podcast: \(error)")
        }
    }
    
    func toggleFavorite(_ podcast: Episode) {
        podcast.isFavorite.toggle()
    }
    
    func download(_ episode: Episode, authManager: AuthManager) async throws {
        guard downloads[episode.serverId] == nil,
              episode.isDownloaded == false
        else { return }
        
        let request = try client.createRequest(for: "podcasts/\(episode.serverId)/download")
        
        let download = Download(request: request)
        
        downloads[episode.serverId] = download
        download.start()
        episode.downloadState = .downloading
        for await event in download.events {
            process(event, for: episode)
        }
        
        downloads[episode.serverId] = nil
    }
    
    func removeDownload(for podcast: Episode) {
        downloads[podcast.serverId]?.cancel()
        try? FileManager.default.removeItem(at: podcast.fileURL)
        podcast.downloadState = .idle
        podcast.isDownloaded = false
    }

    
    func process(_ event: Download.Event, for episode: Episode) {
        switch event {
        case let .progress(current, total):
            episode.update(currentBytes: current, totalBytes: total)
            print(episode.downloadProgress)
        case let .completed(url):
            episode.downloadState = .idle
            defer { try? FileManager.default.removeItem(at: url) } // Clean up temp file
            let didSave = save(episode, from: url)
            episode.isDownloaded = didSave
        case .canceled:
            episode.downloadState = .idle
        }
    }
    
    func save(_ episode: Episode, from url: URL) -> Bool {
        let fileManager = FileManager.default
        let destinationURL = episode.fileURL
        do {
            // Create intermediate directories if they don't exist
            let destinationDirectory = destinationURL.deletingLastPathComponent()
            try fileManager.createDirectory(at: destinationDirectory,
                                            withIntermediateDirectories: true)
            
            // Remove existing file if it exists
            try? fileManager.removeItem(at: destinationURL)

            // Move the file
            try fileManager.moveItem(at: url, to: destinationURL)
            return true
        } catch {
            print("Failed to save podcast \(episode.id): \(error)")
            return false
        }
    }
}
