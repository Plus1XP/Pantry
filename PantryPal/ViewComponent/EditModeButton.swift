//
//  EditButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct EditModeButton: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var noteStore: NoteStore
    @Binding var editMode: EditMode
    
    var body: some View {
        Button {
//            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
//            impactFeedback.impactOccurred()
            if self.editMode == .inactive {
//                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
//                feedbackGenerator?.notificationOccurred(.success)
                self.editMode = .active
            }
            else if self.editMode == .active {
//                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
//                feedbackGenerator?.notificationOccurred(.warning)
                self.itemStore.itemSelection.removeAll()
                self.noteStore.noteSelection.removeAll()
                self.editMode = .inactive
            }
        } label: {
            if self.editMode.isEditing {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white, .blue)
            } else {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.gray, .blue)
            }
        }
        .scaleEffect(self.editMode.isEditing ? 1.5 : 1)
        .animation(.bouncy, value: self.editMode.isEditing)
    }
}

#Preview {
    @State var items: Set<Item> = [PersistenceController.preview.sampleItem]
    @State var notes: Set<Note> = [PersistenceController.preview.sampleNote]

    return EditModeButton(editMode: .constant(EditMode.inactive))
        .environmentObject(ItemStore())
        .environmentObject(NoteStore())
}
