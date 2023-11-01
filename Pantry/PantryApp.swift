//
//  PantryApp.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import SwiftUI

@main
struct PantryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
