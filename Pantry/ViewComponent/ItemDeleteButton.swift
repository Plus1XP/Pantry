//
//  ItemDeleteButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct ItemDeleteButton: View {
    @Binding var confirmDeletion: Bool
    
    var body: some View {
        Button(action: {
            self.confirmDeletion = true
        }) {
            Label("Trash", systemImage: "trash")
        }
    }
}

#Preview {
    ItemDeleteButton(confirmDeletion: .constant(false))
}