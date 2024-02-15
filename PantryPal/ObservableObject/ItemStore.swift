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

    var searchResults: [Item] {
        guard !self.searchText.isEmpty else { return self.items }
        return self.items.filter { $0.name!.contains(self.searchText)
        }
    }
    
    init() {
        fetchEntries()
//        deleteCoreData()
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
    
    func updateEntry(entry: Item) {
//        entry.updated = Date()
//        if list.value(forKey: "createdAt") == nil {
//                list.setValue(Date(), forKey: "createdAt")
//            }
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
        for entry in self.itemSelection {
            PersistenceController.shared.container.viewContext.delete(entry)
        }
        self.itemSelection.removeAll()
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteAll() {
        for item in self.items {
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
        for entry in self.itemSelection {
            entry.quantity = entry.total
            entry.modified = Date()
        }
        self.itemSelection.removeAll()
        self.sortEntries()
        self.saveChanges()
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
