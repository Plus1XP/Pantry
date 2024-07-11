//
//  NoteUndoButton.swift
//  PantryPal
//
//  Created by nabbit on 11/07/2024.
//

import SwiftUI

struct NoteUndoButton: View {
    @EnvironmentObject var noteStore: NoteStore
    @State var animate: Bool = false
    
    var body: some View {
            Button(action: {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                self.noteStore.undoDeleteChanges()
//                self.animate.toggle()
            }) {
                Image(systemName: self.noteStore.noteCache.isEmpty ? "arrowshape.turn.up.backward" : "arrowshape.turn.up.backward.badge.clock.fill")
                    .symbolEffect(
                        .bounce.up.byLayer,
                        options: .speed(1).repeat(1),
                        value: self.noteStore.noteCache.isEmpty
                    )
                    .contentTransition(.symbolEffect(.replace))
                    .rotationEffect(.degrees(self.animate ? -360 : 0))
            }
            .foregroundStyle(self.noteStore.noteCache.isEmpty ? .gray : .blue)
            .disabled(self.noteStore.noteCache.isEmpty)
    }
}

#Preview {
    @State var notes: Set<Note> = [PersistenceController.preview.sampleNote]
    
    return NoteUndoButton()
        .environmentObject(NoteStore())
}
