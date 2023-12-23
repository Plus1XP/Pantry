//
//  ItemDeleteButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct ItemDeleteButton: View {
    @State var animate: Bool = false
    @Binding var confirmDeletion: Bool

    var body: some View {
        Button(action: {
            self.animate.toggle()
            self.confirmDeletion = true
        }) {
            Label("Trash", systemImage: self.confirmDeletion ? "trash.fill" : "trash")
                .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: self.animate)
                .contentTransition(.symbolEffect(.replace))
        }
        .onDisappear(perform: {
            self.animate.toggle()
        })
    }
}

#Preview {
    ItemDeleteButton(confirmDeletion: .constant(false))
}
