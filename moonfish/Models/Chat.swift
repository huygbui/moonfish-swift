//
//  Chat.swift
//  moonfish
//
//  Created by Huy Bui on 14/4/25.
//

import Foundation
import SwiftData


let sqlFormatStyle = Date.FormatStyle()
        .year(.defaultDigits)
        .month(.twoDigits)
        .day(.twoDigits)
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)


enum Role: Codable {
    case model
    case user
}


enum Remote {
    struct Chat: Identifiable, Hashable, Codable {
        var id: Int
        var title: String?
        var status: String
        var createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case status
            case createdAt = "created_at"
        }
    }
}


@Model
final class Chat {
    var remoteId: Int
    var title: String?
    var status: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var messages = [Message]()
    
    init(remoteId: Int, title: String? = nil, status: String, createdAt: Date) {
        self.remoteId = remoteId
        self.title = title
        self.status = status
        self.createdAt = createdAt
    }
    
    convenience init?(from remoteChat: Remote.Chat) {
        guard let parsedDate = try? Date(
            remoteChat.createdAt,
            strategy: sqlFormatStyle
        ) else {
            return nil
        }
        
        self.init(
            remoteId: remoteChat.id,
            title: remoteChat.title,
            status: remoteChat.status,
            createdAt: parsedDate
        )
    }
}


@Model
final class Message {
    var role : Role
    var content : String
    
    init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

