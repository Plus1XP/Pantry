//
//  NoteDebugButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct NoteDebugButtons: View {
    @EnvironmentObject var noteStore: NoteStore

    var body: some View {
        Button(action: {
            self.noteStore.samepleNotes()
        }) {
            Label("Mock Data", systemImage: "plus.circle.fill")
                .foregroundStyle(.white, .green)
        }
        Button(action: {
            self.noteStore.deleteAll()
        }) {
            Label("Mock Data", systemImage: "minus.circle.fill")
                .foregroundStyle(.white, .red)
        }    }
}

#Preview {
    HStack {
        NoteDebugButtons()
    }
    .environmentObject(NoteStore())
    .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
}
