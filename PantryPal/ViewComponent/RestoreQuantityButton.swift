//
//  ItemRepeatButton.swift
//  PantryPal
//
//  Created by nabbit on 22/12/2023.
//

import SwiftUI

struct RestoreQuantityButton: View {
    @Binding var confirmRestoreQuantity: Bool
    
    var body: some View {
        Button(action: {
            self.confirmRestoreQuantity = true
        }) {
            Label("Repeat", systemImage: "repeat.circle")
        }
    }
}

#Preview {
RestoreQuantityButton(confirmRestoreQuantity: .constant(false))
}
