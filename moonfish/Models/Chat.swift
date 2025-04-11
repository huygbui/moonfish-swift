//
//  Chat.swift
//  moonfish
//
//  Created by Huy Bui on 11/4/25.
//

import Foundation

struct Chat: Identifiable, Hashable, Codable {
    var id: Int
    var title: String
    var status: String
    var createdAt: String
}
