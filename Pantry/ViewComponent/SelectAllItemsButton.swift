//
//  SelectAllItemsButton.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct SelectAllItemsButton: View {
    @EnvironmentObject var itemStore: ItemStore
    @Binding var selectedItems: Set<Item>
    
    var body: some View {
        Button(action: {
            if self.selectedItems.isEmpty {
                for item in self.itemStore.items {
                    self.selectedItems.insert(item)
                }
            } else {
                self.selectedItems.removeAll()
            }
        }) {
            Image(systemName: self.selectedItems.isEmpty ? "checklist.unchecked" : "checklist.checked")
        }
    }
}

#Preview {
    @State var items: Set<Item> = [PersistenceController.preview.sampleItem]
    return SelectAllItemsButton(selectedItems: $items)
}
