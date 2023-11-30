//
//  ItemStore.swift
//  Pantry
//
//  Created by nabbit on 09/11/2023.
//

import CoreData

class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    
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
    
    func addNewEntry(name: String?, quantity: Int64?, total: Int64?, notes: String?) {
        let newItem = Item(context: PersistenceController.shared.container.viewContext)
        newItem.id = UUID()
        newItem.position = Int64(items.count + 1)
        newItem.name = name
        newItem.quantity = quantity ?? 0
        newItem.total = total ?? 0
        newItem.notes = notes
        newItem.created = Date()
        newItem.modified = Date()
        saveChanges()
    }
    
    func updateEntry(entry: Item) {
//        entry.updated = Date()
//        if list.value(forKey: "createdAt") == nil {
//                list.setValue(Date(), forKey: "createdAt")
//            }
        saveChanges()
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
        PersistenceController.shared.container.viewContext.delete(entry)
        saveChanges()
    }
    
    func deleteEntry(offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(PersistenceController.shared.container.viewContext.delete)
        saveChanges()
    }
    
    func deleteAll() {
        for item in self.items {
            PersistenceController.shared.container.viewContext.delete(item)
        }
        saveChanges()
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
            positionCount += 1
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
            item.notes = "We live as we die, Alone.."
            item.created = Date()
            item.modified = Date().addingTimeInterval(30000000)
            loopCount += 1
        }
        do {
            saveChanges()
        }
    }
}
