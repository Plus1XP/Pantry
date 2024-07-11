//
//  NoteCache.swift
//  PantryPal
//
//  Created by nabbit on 11/07/2024.
//

import Foundation

class NoteCache {
    var id: UUID?
    var position: Int64?
    var name: String?
    var body: String?
    var isPinned: Bool?
    var switchTitle: String?
    var isSwitchOn: Bool?
    var created: Date?
    var modified: Date?
    
    init(id: UUID?, position: Int64?, name: String?, body: String?, isPinned: Bool?, switchTitle: String?, isSwitchOn: Bool?, created: Date?, modified: Date?) {
        self.id = id
        self.position = position
        self.name = name
        self.body = body
        self.isPinned = isPinned
        self.switchTitle = switchTitle
        self.isSwitchOn = isSwitchOn
        self.created = created
        self.modified = modified
    }
}
