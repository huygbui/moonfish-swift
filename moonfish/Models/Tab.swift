//
//  Tab.swift
//  moonfish
//
//  Created by Huy Bui on 15/5/25.
//

import Foundation

enum Tab: String, Identifiable, CaseIterable {
    case all = "All"
    case completed = "Completed"
    case onGoing = "On-Going"
    case downloaded = "Downloaded"
    case favorite = "Favorite"

    var id: Self { self }
}
