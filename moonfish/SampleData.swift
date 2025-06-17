//
//  SampleData.swift
//  moonfish
//
//  Created by Huy Bui on 10/5/25.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    static let shared = SampleData()
    
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    private init() {
        let schema = Schema([Podcast.self])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            insertSampleData()
            
            try context.save()
        } catch {
            fatalError("Unable to initialize ModelContainer: \(error)")
        }
    }
    
    private func insertSampleData() {
        for request in Podcast.sampleData {
            context.insert(request)
        }
    }
}
