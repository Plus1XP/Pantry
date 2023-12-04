//
//  PinnedNotesButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct PinnedNotesButton: View {
    @Binding var canShowPinnedNotes: Bool
    
    var body: some View {
        Button(action: {
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            self.canShowPinnedNotes.toggle()
        }) {
            Label("Pinned Notes", systemImage: self.canShowPinnedNotes ? "pin.fill" : "pin")
        }
    }
}

#Preview {
    PinnedNotesButton(canShowPinnedNotes: .constant(false))
}
