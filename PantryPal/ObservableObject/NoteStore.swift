//
//  NoteStore.swift
//  Pantry
//
//  Created by nabbit on 12/11/2023.
//

import CoreData

class NoteStore: ObservableObject {
    @Published var notes: [Note] = []
    @Published var noteSelection: Set<Note> = []
    @Published var searchText: String = ""
    @Published var isPinnedNotesFiltered: Bool = false
    
    var noteCache: [NoteCache] = []
    var notePositionState: [UUID:Int64] = [:]
    var searchResults: [Note] {
        guard !self.searchText.isEmpty else { return self.notes }
        return self.notes.filter { $0.name!.localizedCaseInsensitiveContains(self.searchText)
        }
    }
    
    var pinnedResults: [Note] {
        guard self.isPinnedNotesFiltered else { return self.notes }
        return self.notes.filter{ $0.isPinned }
    }
    
    var combinedResults: [Note] {
        let pinnedResults = self.pinnedResults
        guard !self.searchText.isEmpty else { return pinnedResults }
        return pinnedResults.filter { $0.name!.localizedCaseInsensitiveContains(self.searchText)
        }
    }
    
    init() {
        fetchEntries()
    }
    
    func fetchEntries() {
        let request = NSFetchRequest<Note>(entityName: "Note")
        let sort = NSSortDescriptor(key: "position", ascending: true)
                request.sortDescriptors = [sort]
        do {
            notes = try PersistenceController.shared.container.viewContext.fetch(request)
        } catch {
            print("Error fetching. \(error)")
        }
    }
    
    func addNewEntry(name: String?, body: String?, switchTitle: String, isSwitchOn: Bool, isPinned: Bool?) {
        let newNote = Note(context: PersistenceController.shared.container.viewContext)
        newNote.id = UUID()
        newNote.position = Int64(notes.count == 0 ? 0 : notes.count + 1)
        newNote.name = name
        newNote.body = body
        newNote.isPinned = isPinned ?? false
        newNote.switchTitle = switchTitle
        newNote.isSwitchOn = isSwitchOn
        newNote.created = Date()
        newNote.modified = Date()
        self.saveChanges()
    }
    
    func addNewEntryFromCache(id: UUID?, position: Int64?, name: String?, body: String?, isPinned: Bool?, switchTitle: String?, isSwitchOn: Bool?, created: Date?, modified: Date?) {
        let cachedNote = Note(context: PersistenceController.shared.container.viewContext)
        cachedNote.id = id
        cachedNote.position = ((position ?? Int64(notes.count == 0 ? 0 : notes.count + 1)) - 1)
        cachedNote.name = name
        cachedNote.body = body
        cachedNote.isPinned = isPinned ?? false
        cachedNote.switchTitle = switchTitle
        cachedNote.isSwitchOn = isSwitchOn ?? false
        cachedNote.created = created
        cachedNote.modified = modified
        self.saveChanges()
    }
    
    func updateEntry(entry: Note) {
//        entry.updated = Date()
//        if list.value(forKey: "createdAt") == nil {
//                list.setValue(Date(), forKey: "createdAt")
//            }
        self.saveChanges()
    }
    
    func updatePin(entry: Note) {
        entry.isPinned.toggle()
//        entry.modified = Date()
        self.noteSelection.removeAll()
        self.saveChanges()
    }
    
    func sortEntries() {
        PersistenceController.shared.container.viewContext.perform {
            let revisedEntries: [Note] = self.notes.map({$0})
            for reverseIndex in stride(from: revisedEntries.count-1, through: 0, by: -1) {
                revisedEntries[reverseIndex].position = Int64(reverseIndex)
            }
            self.saveChanges()
        }
    }
    
    func moveEntry(from oldIndex: IndexSet, to newIndex: Int) {
        // This guarantees that the edits are performed in the same thread as the CoreData context
        PersistenceController.shared.container.viewContext.perform {
            var revisedEntries: [Note] = self.notes.map({$0})
            revisedEntries.move(fromOffsets: oldIndex, toOffset: newIndex)
            for reverseIndex in stride(from: revisedEntries.count-1, through: 0, by: -1) {
                revisedEntries[reverseIndex].position = Int64(reverseIndex)
            }
            self.saveChanges()
        }
    }
    
    func deleteEntry(entry: Note) {
        self.noteCache.removeAll()
        self.cacheChanges(entry: entry)
        PersistenceController.shared.container.viewContext.delete(entry)
        self.noteSelection.removeAll()
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteEntry(offsets: IndexSet) {
        offsets.map { notes[$0] }.forEach(PersistenceController.shared.container.viewContext.delete)
        self.noteSelection.removeAll()
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteEntries(selection: Set<Note>) {
        for entry in selection {
            PersistenceController.shared.container.viewContext.delete(entry)
        }
        self.noteSelection.removeAll()
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteNoteSelectionEntries() {
        self.noteCache.removeAll()
        for entry in self.noteSelection {
            self.cacheChanges(entry: entry)
            PersistenceController.shared.container.viewContext.delete(entry)
        }
        self.noteSelection.removeAll()
        self.sortEntries()
        self.saveChanges()
    }
    
    func deleteAll() {
        self.noteCache.removeAll()
        for note in self.notes {
            self.cacheChanges(entry: note)
            PersistenceController.shared.container.viewContext.delete(note)
        }
        self.saveChanges()
    }

    func cacheEntryPosition() -> Void {
        for entry in notes {
            self.notePositionState[entry.id ?? UUID()] = entry.position
        }
    }
    
    func restoreEntryPosition() -> Void {
        for entry in notes {
            for position in notePositionState {
                if entry.id == position.key {
                    entry.position = position.value
                }
            }
        }
    }
    
    func cacheChanges(entry: Note) -> Void {
        self.cacheEntryPosition()
        noteCache.append(NoteCache(id: entry.id, position: entry.position, name: entry.name, body: entry.body, isPinned: entry.isPinned, switchTitle: entry.switchTitle, isSwitchOn: entry.isSwitchOn, created: entry.created, modified: entry.modified))
        self.saveChanges()
    }
    
    func undoDeleteChanges() -> Void {
        for entry in noteCache {
            addNewEntryFromCache(id: entry.id, position: entry.position, name: entry.name, body: entry.body, isPinned: entry.isPinned, switchTitle: entry.switchTitle, isSwitchOn: entry.isSwitchOn, created: entry.created, modified: entry.modified)
        }
        self.restoreEntryPosition()
        self.noteCache.removeAll()
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
    
    func samepleNotes() {
        var loopCount = 0
        var positionCount = notes.count
        for _ in 0..<6 {
            let context = PersistenceController.shared.container.viewContext
            let note = Note(context: context)
            let name = ["Favourite Stores", "Excluded Brands", "Allergies", "Offers", "Protein Rich"]
            let body = ["The devil watches over his own", "Youth is wasted on the young.", "We live as we dream.... Alone.", "Rules only exist if you follow them.", "Seeking is not always the way to find. "]
            let isPinned = [true, false]
            note.id = UUID()
            note.position = Int64(positionCount)
            note.name = name.randomElement()
            note.body = body.randomElement()
            note.isPinned = isPinned.randomElement() ?? false
            note.switchTitle = "Task Completed?"
            note.isSwitchOn = true
            note.created = Date()
            note.modified = Date().addingTimeInterval(30000000)
            loopCount += 1
            positionCount += 1
        }
        do {
            self.saveChanges()
        }
    }
}
