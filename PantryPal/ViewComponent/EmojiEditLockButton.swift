//
//  LockEmojiEditButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct EmojiEditLockButton: View {
    @Binding var canEditEmojis: Bool
    
    var body: some View {
        Button(action: {
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            self.canEditEmojis.toggle()
        }) {
            Label("Lock Emojis", systemImage: self.canEditEmojis ? "hand.tap" : "hand.tap")
        }
    }
}

#Preview {
    EmojiEditLockButton(canEditEmojis: .constant(false))
}
