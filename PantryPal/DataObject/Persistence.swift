//
//  Persistence.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        var count = 0
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.position = Int64(count)
            newItem.name = "🥥"
            newItem.quantity = 3
            newItem.total = 5
            newItem.bulkprice = 4.00
            newItem.unitprice = 1.00
            newItem.created = Date()
            newItem.modified = Date()
            newItem.note = "Some bullshit here"
            let newNote = Note(context: viewContext)
            newNote.id = UUID()
            newNote.position = Int64(count)
            newNote.name = "my Secret"
            newNote.body = "Im really happy!"
            newNote.isPinned = false
            newNote.switchTitle = "Task Completed?"
            newNote.isSwitchOn = false
            newNote.created = Date()
            newNote.modified = Date()
            count += 1
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Pantry")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    //Added this!
    func saveContext(completionHandler: @escaping (Error?) -> Void) {
        if PersistenceController.shared.container.viewContext.hasChanges {
            do {
                try PersistenceController.shared.container.viewContext.save()
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }
    
    func RemoveiCloudData(completion: @escaping (_ response: Bool) -> Void) {
        // replace the identifier with your container identifier
        let container = CKContainer(identifier: "iCloud.io.plus1xp.pantry")
        let database = container.privateCloudDatabase
        
        // instruct iCloud to delete the whole zone (and all of its records)
        database.delete(withRecordZoneID: .init(zoneName: "com.apple.coredata.cloudkit.zone"), completionHandler: { (zoneID, error) in
            if let error = error {
                completion(false)
                debugPrint("error deleting zone: - \(error.localizedDescription)")
            } else {
                completion(true)
                debugPrint("successfully deleted zone")
            }
        })
    }
}
