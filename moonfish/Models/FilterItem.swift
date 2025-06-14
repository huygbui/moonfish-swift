//
//  Tab.swift
//  moonfish
//
//  Created by Huy Bui on 15/5/25.
//

import Foundation

enum FilterItem: String, Identifiable, CaseIterable {
    case all = "All"
    case favorite = "Favorite"
    case downloaded = "Downloaded"

    var id: Self { self }
}
