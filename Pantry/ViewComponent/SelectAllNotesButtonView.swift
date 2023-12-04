//
//  SelectAllNotesButtonView.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct SelectAllNotesButton: View {
    @EnvironmentObject var noteStore: NoteStore
    @Binding var selectedNotes: Set<Note>
    
    var body: some View {
        Button(action: {
            if self.selectedNotes.isEmpty {
                for note in self.noteStore.notes {
                    self.selectedNotes.insert(note)
                }
            } else {
                self.selectedNotes.removeAll()
            }
        }) {
            Image(systemName: self.selectedNotes.isEmpty ? "checklist.unchecked" : "checklist.checked")
        }
    }
}

//#Preview {
//    SelectAllNotesButton()
//}
