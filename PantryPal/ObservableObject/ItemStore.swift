//
//  ItemStore.swift
//  Pantry
//
//  Created by nabbit on 09/11/2023.
//

import CoreData

class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    @Published var itemSelection: Set<Item> = []
    @Published var searchText: String = ""
    
    var hasRestoredItemQuantity: Bool = false
    var itemCache: [ItemCache] = []
    var searchResults: [Item] {
        guard !self.searchText.isEmpty else { return self.items }
        return self.items.filter { $0.name!.contains(self.searchText)
        }
    }
    
    init() {
        fetchEntries()
    }
    
//    #if DEBUG
//    func fetchEntries() {
//        let request = NSFetchRequest<Item>(entityName: "Item")
//        let sort = NSSortDescriptor(key: "created", ascending: true)
//                request.sortDescriptors = [sort]
//        do {
//            items = try PersistenceController.preview.container.viewContext.fetch(request)
//        } catch {
//            print("Error fetching. \(error)")
//        }
//    }
//    #else
    func fetchEntries() {
        let request = NSFetchRequest<Item>(entityName: "Item")
        let sort = NSSortDescriptor(key: "position", ascending: true)
                request.sortDescriptors = [sort]
        do {
            items = try PersistenceController.shared.container.viewContext.fetch(request)
        } catch {
            print("Error fetching. \(error)")
        }
    }
//    #endif
    
    func addNewEntry(name: String?, quantity: Int64?, total: Int64?, bulkPrice: Double?, unitPrice: Double?, note: String?) {
        let newItem = Item(context: PersistenceController.shared.container.viewContext)
        newItem.id = UUID()
        newItem.position = Int64(items.count == 0 ? 0 : items.count + 1)
        newItem.name = name
        newItem.quantity = quantity ?? 0
        newItem.total = total ?? 0
        newItem.bulkprice = bulkPrice ?? 0.00
        newItem.unitprice = unitPrice ?? 0.00
        newItem.note = note
        newItem.created = Date()
        newItem.modified = Date()
        self.saveChanges()
    }
    
    func addNewEntryFromCache(id: UUID?, position: Int64?, name: String?, quantity: Int64?, total: Int64?, bulkprice: Double?, unitprice: Double?, note: String?, created: Date?, modified: Date?) {
        let cachedItem = Item(context: PersistenceController.shared.container.viewContext)
        cachedItem.id = id
        cachedItem.position = ((position ?? Int64(items.count == 0 ? 0 : items.count + 1)) - 1)
        cachedItem.name = name
        cachedItem.quantity = quantity ?? 0
        cachedItem.total = total ?? 0
        cachedItem.bulkprice = bulkprice ?? 0.00
        cachedItem.unitprice = unitprice ?? 0.00
        cachedItem.note = note
        cachedItem.created = created
        cachedItem.modified = modified
        self.saveChanges()
    }
    
    func updateEntry(entry: Item) {
//        entry.updated = Date()
//        if list.value(forKey: "createdAt") == nil {
//                list.setValue(Date(), forKey: "createdAt")
//            }
        self.saveChanges()
    }
    
    func updateEntryQuantity(entry: Item, entryQuantity: Int64) -> Void {
        self.hasRestoredItemQuantity = true
        self.itemCache.removeAll()
        self.cacheChanges(entry: entry)
        entry.quantity = entryQuantity
        entry.modified = Date()
        self.saveChanges()
    }
    
    func sortEntries() {
        PersistenceController.shared.container.viewContext.perform {
            let revisedEntries: [Item] = self.items.map({$0})
            for reverseIndex in stride(from: revisedEntries.count-1, through: 0, by: -1) {
                revisedEntries[reverseIndex].position = Int64(reverseIndex)
            }
            self.saveChanges()
        }
    }
    
    func moveEntry(from oldIndex: IndexSet, to newIndex: Int) {
        // This guarantees that the edits are performed in the same thread as the CoreData context
        PersistenceController.shared.container.viewContext.perform {
            var revisedItems: [Item] = self.items.map({$0})
            revisedItems.move(fromOffsets: oldIndex, toOffset: newIndex)
            for reverseIndex in stride(from: revisedItems.count-1, through: 0, by: -1) {
                revisedItems[reverseIndex].position = Int64(reverseIndex)
            }
            self.saveChanges()
        }
    }
    
    func deleteEntry(entry: Item) {
        self.hasRestoredItemQuantity = false
        self.itemCache.removeAll()
        self.cacheChanges(entry: entry)
        PersistenceController.shared.container.viewContext.delete(entry)
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteEntry(offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(PersistenceController.shared.container.viewContext.delete)
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteEntries(selection: Set<Item>) {
        for entry in selection {
            PersistenceController.shared.container.viewContext.delete(entry)
        }
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteItemSelectionEntries() {
        self.hasRestoredItemQuantity = false
        self.itemCache.removeAll()
        for entry in self.itemSelection {
            self.cacheChanges(entry: entry)
            PersistenceController.shared.container.viewContext.delete(entry)
        }
        self.itemSelection.removeAll()
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteAll() {
        self.hasRestoredItemQuantity = false
        self.itemCache.removeAll()
        for item in self.items {
            self.cacheChanges(entry: item)
            PersistenceController.shared.container.viewContext.delete(item)
        }
        self.saveChanges()
    }
    
    func deleteCoreData() {
        PersistenceController.shared.RemoveiCloudData() { (result) in
            if result {
                debugPrint("Core Data delete Sucess")
            } else {
                debugPrint("Core Data delete Fail")
            }
        }
    }
    
    func restoreQuantityItemSelectionEntries() {
        self.hasRestoredItemQuantity = true
        self.itemCache.removeAll()
        for entry in self.itemSelection {
            self.cacheChanges(entry: entry)
            entry.quantity = entry.total
            entry.modified = Date()
        }
        self.itemSelection.removeAll()
        self.sortEntries()
        self.saveChanges()
    }
    
    func cacheChanges(entry: Item) -> Void {
        itemCache.append(ItemCache(id: entry.id, position: entry.position, name: entry.name, quantity: entry.quantity, total: entry.total, bulkprice: entry.bulkprice, unitprice: entry.unitprice, note: entry.note, created: entry.created, modified: entry.modified))
        self.saveChanges()
    }
    
    func undoDeleteChanges() -> Void {
        self.hasRestoredItemQuantity = false
        for entry in itemCache {
            addNewEntryFromCache(id: entry.id, position: entry.position, name: entry.name, quantity: entry.quantity, total: entry.total, bulkprice: entry.bulkprice, unitprice: entry.unitprice, note: entry.note, created: entry.created, modified: entry.modified)
        }
        self.itemCache.removeAll()
        self.sortEntries()
        self.saveChanges()
    }
    
    func undoRestoreChanges() -> Void {
        self.hasRestoredItemQuantity = false
        for entry in itemCache {
//            let unrestoredItems = items.filter { $0.id == entry.id }
            for item in items {
                if item.id == entry.id {
                    item.quantity = entry.quantity ?? 0
                    item.modified = entry.modified
                }
            }
        }
        self.itemCache.removeAll()
        self.saveChanges()
    }
    
    func validateUndoMethod() -> Void {
        if hasRestoredItemQuantity {
            undoRestoreChanges()
        } else {
            undoDeleteChanges()
        }
    }
    
    func discardChanges() {
        PersistenceController.shared.container.viewContext.rollback()
        self.fetchEntries()
    }
    
    func saveChanges() {
        PersistenceController.shared.saveContext() { error in
            guard error == nil else {
                print("An error occurred while saving: \(error!)")
                return
            }
            self.fetchEntries()
        }
    }
    
    func sampleItems() {
        var loopCount = 0
        var positionCount = items.count
        for _ in 0..<6 {
            let context = PersistenceController.shared.container.viewContext
            let item = Item(context: context)
            let name = ["🍎", "🥝", "🍌", "🍉", "🥥"]
            let quantity = [3, 2, 5, 1, 5, 3, 1]
            let total = [5, 2, 6, 3, 7, 4, 1]
            item.id = UUID()
            item.position = Int64(positionCount)
            item.name = name.randomElement()
            item.quantity = Int64(quantity[0 + loopCount])
            item.total = Int64(total[0 + loopCount])
            item.bulkprice = 4.00
            item.unitprice = 1.00
            item.note = "We live as we die, Alone.."
            item.created = Date()
            item.modified = Date().addingTimeInterval(30000000)
            loopCount += 1
            positionCount += 1
        }
        do {
            self.saveChanges()
        }
    }
}
