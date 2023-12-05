//
//  SelectAllNotesButtonView.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct SelectAllNotesButton: View {
    @EnvironmentObject var noteStore: NoteStore
    
    var body: some View {
        Button(action: {
            if self.noteStore.noteSelection.isEmpty {
                for note in self.noteStore.notes {
                    self.noteStore.noteSelection.insert(note)
                }
            } else {
                self.noteStore.noteSelection.removeAll()
            }
        }) {
            Image(systemName: self.noteStore.noteSelection.isEmpty ? "checklist.unchecked" : "checklist.checked")
        }
    }
}

#Preview {
    @State var notes: Set<Note> = [PersistenceController.preview.sampleNote]
    
    return SelectAllNotesButton()
        .environmentObject(NoteStore())
}
