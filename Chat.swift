//
//  Chat.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 22/07/24.
//

import Foundation

enum ChatRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID().uuidString
    var role: ChatRole
    var message: String
    var images: [Data]?
}
