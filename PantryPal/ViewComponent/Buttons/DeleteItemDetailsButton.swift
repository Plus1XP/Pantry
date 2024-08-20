//
//  DeleteDetailsButton.swift
//  PantryPal
//
//  Created by nabbit on 20/08/2024.
//

import SwiftUI

struct DeleteItemDetailsButton: View {
    @Environment(\.presentationMode) var presentaionMode
    @EnvironmentObject var itemStore: ItemStore
    @State var confirmDeletion: Bool = false
    @State var animate: Bool = false
    let item: Item

    var body: some View {
        Button(action: {
            self.animate.toggle()
            self.confirmDeletion = true
        }, label: {
            Image(systemName: self.confirmDeletion ? "trash.fill" : "trash")
                .font(.headline)
                .foregroundStyle(.red)
                .symbolEffect(.pulse.wholeSymbol, options: .repeat(3), value: self.animate)
                .contentTransition(.symbolEffect(.replace))
        })
        .alert("Confirm Deletion", isPresented: $confirmDeletion) {
            Button("Cancel", role: .cancel) {
                self.confirmDeletion = false
            }
            Button("Delete", role: .destructive) {
                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                feedbackGenerator?.notificationOccurred(.success)
                itemStore.deleteEntry(entry: item)
                self.confirmDeletion = false
                self.presentaionMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete the Entry?")
        }
    }
}

#Preview {
    DeleteItemDetailsButton(item: PersistenceController.preview.sampleItem)
        .environmentObject(ItemStore())
}
