//
//  EditButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct EditModeButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var editMode: EditMode
    @Binding var selectedItems: Set<Item>
    @Binding var selectedNotes: Set<Note>
    
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
                self.selectedItems.removeAll()
                self.selectedNotes.removeAll()
                self.editMode = .inactive
            }
        } label: {
            if self.editMode.isEditing {
                Image(systemName: "line.3.horizontal.circle.fill")
                    .foregroundStyle(colorScheme == .light ? .white : .black, colorScheme == .light ? .black : .white)
            } else {
                Image(systemName: "line.3.horizontal.circle")
                    .foregroundStyle(setFontColor(colorScheme: colorScheme), setFontColor(colorScheme: colorScheme))
            }
        }
    }
}

//#Preview {
//    EditButtonView()
//}
