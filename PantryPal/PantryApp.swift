//
//  PantryApp.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import SwiftUI

@main
struct PantryApp: App {
//    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var itemStore = ItemStore()
    @StateObject private var noteStore = NoteStore()
    @StateObject private var biometricStore = BiometricStore()

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(self.itemStore)
                .environmentObject(self.noteStore)
                .environmentObject(self.biometricStore)
        }
//        .onChange(of: scenePhase) { phase in
//                    switch phase {
//                    case .active:
//                        debugPrint("active")
//                    case .inactive:
//                        debugPrint("inactive")
//                    case .background:
//                        debugPrint("background")
//                    }
//                }
    }
}
