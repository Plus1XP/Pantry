//
//  NoteStore.swift
//  Pantry
//
//  Created by nabbit on 12/11/2023.
//

import CoreData

class NoteStore: ObservableObject {
    @Published var notes: [Note] = []
    
    init() {
        fetchEntries()
    }
    
    func fetchEntries() {
        let request = NSFetchRequest<Note>(entityName: "Note")
        let sort = NSSortDescriptor(key: "created", ascending: true)
                request.sortDescriptors = [sort]
        do {
            notes = try PersistenceController.shared.container.viewContext.fetch(request)
        } catch {
            print("Error fetching. \(error)")
        }
    }
    
    func addNewEntry(name: String?, noteBody: String?, isPinned: Bool?) {
        let newNote = Note(context: PersistenceController.shared.container.viewContext)
        newNote.id = UUID()
        newNote.name = name
        newNote.body = noteBody
        newNote.isPinned = isPinned ?? false
        newNote.created = Date()
        newNote.modified = Date()
        saveChanges()
    }
    
    func updateEntry(entry: Note) {
//        entry.updated = Date()
//        if list.value(forKey: "createdAt") == nil {
//                list.setValue(Date(), forKey: "createdAt")
//            }
        saveChanges()
    }
    
    func deleteEntry(entry: Note) {
        PersistenceController.shared.container.viewContext.delete(entry)
        saveChanges()
    }
    
    func deleteEntry(offsets: IndexSet) {
        offsets.map { notes[$0] }.forEach(PersistenceController.shared.container.viewContext.delete)
        saveChanges()
    }
    
    func deleteAll() {
        for note in self.notes {
            PersistenceController.shared.container.viewContext.delete(note)
        }
        saveChanges()
    }
    
    func discardChanges() {
        PersistenceController.shared.container.viewContext.rollback()
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
    
//    func move(from oldIndex: IndexSet, to newIndex: Int) {
//        // This guarantees that the edits are performed in the same thread as the CoreData context
//        PersistenceController.shared.container.viewContext.perform {
//            var revisedItems: [Soul] = souls.map({$0})
//            revisedItems.move(fromOffsets: oldIndex, toOffset: newIndex)
//            for reverseIndex in stride(from: revisedItems.count-1, through: 0, by: -1) {
//                revisedItems[reverseIndex].id = Int64(reverseIndex)
//            }
//            PersistenceController.shared.save()
//        }
//    }
    
//    private func onMove(source: IndexSet, to destination: Int) {
//        var revisedItems: [Soul] = souls.sorted(by: { $0.order < $1.order }).map{ $0 }
//
//            CoreDataHelper.executeBlockAndCommit {
//                revisedItems.move(fromOffsets: source, toOffset: destination )
//
//                for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1)
//                {
//                    revisedItems[reverseIndex].order = Int32(reverseIndex)
//                }
//            }
//        }
    
    private func move(from source: IndexSet, to destination: Int) {

//            var revisedAttendees = souls
//
//            revisedAttendees.move(fromOffsets: source, toOffset: destination )
//
//            for reverseIndex in stride( from: revisedAttendees.count - 1, through: 0, by: -1 ) {
//                revisedAttendees[ reverseIndex ].order =
//                    Int16( reverseIndex )
//            }
//            saveChanges()
        }
    
    func samepleNotes() {
        for _ in 0..<6 {
            let context = PersistenceController.shared.container.viewContext
            let note = Note(context: context)
            let name = ["Favourite Stores", "Excluded Brands", "Allergies", "Offers", "Protein Rich"]
            let body = ["The devil watches over his own", "Youth is wasted on the young.", "We live as we dream.... Alone.", "Rules only exist if you follow them.", "Seeking is not always the way to find. "]
            let isPinned = [true, false]
            note.id = UUID()
            note.name = name.randomElement()
            note.body = body.randomElement()
            note.isPinned = isPinned.randomElement() ?? false
            note.created = Date()
            note.modified = Date().addingTimeInterval(30000000)
        }
        do {
            saveChanges()
        }
    }
}
