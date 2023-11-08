//
//  PersistenceController.swift
//  Pantry
//
//  Created by nabbit on 03/11/2023.
//

import Foundation

// demo data
extension PersistenceController {
    var samepleItem: Item {
        let context = PersistenceController.preview.container.viewContext
        let item = Item(context: context)
        item.id = UUID()
        item.name = "👹"
        item.quantity = 3
        item.total = 5
        item.created = Date()
        item.modified = Date().addingTimeInterval(30000000)
        item.notes = "I hope this works"
        return item
    }
    var samepleNote: Note {
        let context = PersistenceController.preview.container.viewContext
        let note = Note(context: context)
        note.id = UUID()
        note.name = "Things to do"
        note.body = "Get a job!"
        note.pinned = true
        note.created = Date()
        note.modified = Date().addingTimeInterval(30000000)
        return note
    }
}
