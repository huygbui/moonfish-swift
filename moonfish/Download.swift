//
//  DownloadController.swift
//  moonfish
//
//  Created by Huy Bui on 22/6/25.
//

import Foundation

final class Download: NSObject {
    let events: AsyncStream<Event>
    private let continuation: AsyncStream<Event>.Continuation
    private let task: URLSessionDownloadTask
    
    enum Event {
        case progress(currentBytes: Int64, totalBytes: Int64)
        case completed(url: URL)
        case canceled
    }
    
    convenience init(request: URLRequest) {
        self.init(task: URLSession.shared.downloadTask(with: request))
    }
    
    convenience init(url: URL) {
        self.init(task: URLSession.shared.downloadTask(with: url))
    }
    
    private init(task: URLSessionDownloadTask) {
        self.task = task
        (events, continuation) = AsyncStream<Event>.makeStream()
        
        super.init()
        
        continuation.onTermination = { @Sendable [weak self] _ in
            self?.cancel()
        }
    }
    
    func start() {
        task.delegate = self
        task.resume()
    }
    
    func cancel() {
        task.cancel { _ in
            self.continuation.yield(.canceled)
            self.continuation.finish()
        }
    }
}

extension Download: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.copyItem(at: location, to: tempURL)
            continuation.yield(.completed(url: tempURL))
        } catch {
            continuation.yield(.canceled)
        }
        continuation.finish()
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        continuation.yield(
            .progress(
                currentBytes: totalBytesWritten,
                totalBytes: totalBytesExpectedToWrite))
    }
}
