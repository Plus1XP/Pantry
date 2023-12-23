//
//  LockEmojiEditButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct EmojiEditLockButton: View {
    @State var animate: Bool = false
    @Binding var canEditEmojis: Bool
    
    var body: some View {
        Button(action: {
            self.animate.toggle()
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            self.canEditEmojis.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animate.toggle()
            }
        }) {
            Label("Lock Emojis", systemImage: self.animate ? "hand.tap.fill" : "hand.tap")
                .symbolEffect(.bounce, value: self.canEditEmojis)
                .contentTransition(.symbolEffect(.replace))
        }
    }
}

#Preview {
    EmojiEditLockButton(canEditEmojis: .constant(false))
}
