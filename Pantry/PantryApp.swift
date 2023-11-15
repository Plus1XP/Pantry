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
    @StateObject private var biometricStore = BiometricStore()
    @StateObject var cloudSyncStore = CloudSyncStore()
    

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(itemStore)
                .environmentObject(noteStore)
                .environmentObject(biometricStore)
                .environmentObject(cloudSyncStore)
        }
    }
}
