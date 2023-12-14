//
//  SelectAllItemsButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct SelectAllItemsButton: View {
    @EnvironmentObject var itemStore: ItemStore
    
    var body: some View {
        Button(action: {
            if self.itemStore.itemSelection.isEmpty {
                for item in self.itemStore.items {
                    self.itemStore.itemSelection.insert(item)
                }
            } else {
                self.itemStore.itemSelection.removeAll()
            }
        }) {
            Image(systemName: self.itemStore.itemSelection.isEmpty ? "checklist.unchecked" : "checklist.checked")
        }
    }
}

#Preview {
    @State var items: Set<Item> = [PersistenceController.preview.sampleItem]
    
    return SelectAllItemsButton()
        .environmentObject(NoteStore())
}
