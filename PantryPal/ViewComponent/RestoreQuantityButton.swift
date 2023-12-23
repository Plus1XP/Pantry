//
//  ItemRepeatButton.swift
//  PantryPal
//
//  Created by nabbit on 22/12/2023.
//

import SwiftUI

struct RestoreQuantityButton: View {
    @State var animate: Bool = false
    @Binding var confirmRestoreQuantity: Bool
    
    var body: some View {
        Button(action: {
            self.animate = true
            self.confirmRestoreQuantity = true
        }) {
            Label("Repeat", systemImage: self.confirmRestoreQuantity ? "repeat.circle.fill" : "repeat.circle")
                .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: self.animate)
                .contentTransition(.symbolEffect(.replace))
        }
        .onDisappear(perform: {
            self.animate = false
        })
    }
}

#Preview {
RestoreQuantityButton(confirmRestoreQuantity: .constant(false))
}
