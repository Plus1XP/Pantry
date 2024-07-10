//
//  ItemCache.swift
//  PantryPal
//
//  Created by nabbit on 10/07/2024.
//

import Foundation

class ItemCache {
    var id: UUID?
    var position: Int64?
    var name: String?
    var quantity: Int64?
    var total: Int64?
    var bulkprice: Double?
    var unitprice: Double?
    var note: String?
    var created: Date?
    var modified: Date?
    
    init(id: UUID?, position: Int64?, name: String?, quantity: Int64?, total: Int64?, bulkprice: Double?, unitprice: Double?, note: String?, created: Date?, modified: Date?) {
        self.id = id
        self.position = position
        self.name = name
        self.quantity = quantity
        self.total = total
        self.bulkprice = bulkprice
        self.unitprice = unitprice
        self.note = note
        self.created = created
        self.modified = modified
    }
}
