//
//  NoteRowView.swift
//  Pantry
//
//  Created by nabbit on 12/11/2023.
//

import SwiftUI

struct NoteRowView: View {
//     Added NoteStore to trigger view refresh when note is changed.
//    @EnvironmentObject var noteStore: NoteStore
    @Binding var note: Note
    
    var body: some View {
        HStack {
            Text(note.name!)
            Spacer()
            Text(Image(systemName: note.isPinned ? "pin.fill" : "pin"))
        }
    }
}

#Preview {
    NoteRowView(note: .constant(PersistenceController.shared.sampleNote))
}
