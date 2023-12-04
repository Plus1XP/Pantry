////
////  AlertView.swift
////  Pantry
////
////  Created by nabbit on 04/12/2023.
////
//
//import SwiftUI
//
//extension ContentView {
//    var AlertView: some View {
//        Alert(title: Text("Confirm Deletion"),
//              message:Text(""),
//              primaryButton: .cancel() {
//            self.selectedItems.removeAll()
//            self.editMode = .inactive
////            self.confirmDeletion = false
//        },
//              secondaryButton: .destructive(Text("Delete")) {
//            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
//            feedbackGenerator?.notificationOccurred(.success)
//            self.itemStore.deleteEntries(selection: self.selectedItems)
//            self.selectedItems.removeAll()
//            self.editMode = .inactive
////            self.confirmDeletion = false
//        })
//    }
//}
//
//#Preview {
//    AlertView()
//}
