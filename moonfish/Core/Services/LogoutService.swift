//
//  LogoutService.swift
//  moonfish
//
//  Created by Huy Bui on 17/7/25.
//

import SwiftUI
import SwiftData

@MainActor
struct LogoutService {
    static func logout(
        auth: AuthManager,
        audio: AudioManager,
        context: ModelContext
    ) async throws {
        audio.resetPlayer()
        purgeDownloads()
        try await purgeData(in: context)
        try auth.signOut()
    }
    
    /// Deletes every `Podcast` and evicts the URL cache.
    private static func purgeData(in context: ModelContext) async throws {
        try context.delete(model: Podcast.self)
        try context.save()
        URLCache.shared.removeAllCachedResponses()
    }
    
    /// Removes every *.mp3* file under the documents directory.
    private static func purgeDownloads() {
        let mp3Files = try? FileManager.default
            .contentsOfDirectory(at: .documentsDirectory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "mp3" }
        
        mp3Files?.forEach { try? FileManager.default.removeItem(at: $0) }
    }
}
