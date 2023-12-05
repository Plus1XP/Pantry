//
//  DeleteSelectionButtonView.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct NoteDeleteButton: View {
    @Binding var selectedNotes: Set<Note>
    @Binding var confirmDeletion: Bool
    
    var body: some View {
        Button(action: {
            self.confirmDeletion = true
        }) {
            Label("Trash", systemImage: "trash")
        }
    }
}

#Preview {
    NoteDeleteButton(selectedNotes: .constant(Set<Note>()), confirmDeletion: .constant(false))
}
