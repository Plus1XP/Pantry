//
//  PinnedNotesButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct PinnedNotesButton: View {
    @EnvironmentObject var noteStore: NoteStore
    
    var body: some View {
        Button(action: {
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            self.noteStore.isPinnedNotesFiltered.toggle()
        }) {
            Label("Pinned Notes", systemImage: self.noteStore.isPinnedNotesFiltered ? "pin.fill" : "pin")
                .symbolEffect(.bounce.down, value: self.noteStore.isPinnedNotesFiltered)
                .contentTransition(.symbolEffect(.replace))
        }
    }
}

#Preview {
    PinnedNotesButton()
        .environmentObject(NoteStore())
}
