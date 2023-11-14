//
//  PantryApp.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import SwiftUI

@main
struct PantryApp: App {
    @StateObject private var itemStore = ItemStore()
    @StateObject private var noteStore = NoteStore()

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(itemStore)
                .environmentObject(noteStore)
        }
    }
}
