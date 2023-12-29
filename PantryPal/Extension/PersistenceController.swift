//
//  PersistenceController.swift
//  Pantry
//
//  Created by nabbit on 03/11/2023.
//

import Foundation

// demo data
extension PersistenceController {
    
    
    var sampleItem: Item {
        let context = PersistenceController.preview.container.viewContext
        let item = Item(context: context)
        item.id = UUID()
        item.name = "👹"
        item.quantity = 3
        item.total = 5
        item.bulkprice = 4.00
        item.unitprice = 1.00
        item.created = Date()
        item.modified = Date().addingTimeInterval(30000000)
        item.note = "I hope this works"
        return item
    }
    var sampleNote: Note {
        let context = PersistenceController.preview.container.viewContext
        let note = Note(context: context)
        note.id = UUID()
        note.name = "Things to do"
        note.body = "Get a job!"
        note.isPinned = true
        note.switchTitle = "Task Completed?"
        note.isSwitchOn = false
        note.created = Date()
        note.modified = Date().addingTimeInterval(30000000)
        return note
    }
    var blankItem: Item {
        let context = PersistenceController.preview.container.viewContext
        let item = Item(context: context)
        item.id = UUID()
        item.name = ""
        item.quantity = 0
        item.total = 0
        item.bulkprice = 0.00
        item.unitprice = 0.00
        item.created = Date()
        item.modified = Date()
        item.note = ""
        return item
    }
}
