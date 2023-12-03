//
//  ItemRowView.swift
//  Pantry
//
//  Created by nabbit on 11/11/2023.
//

import SwiftUI

struct ItemRowView: View {
    @EnvironmentObject var itemStore: ItemStore
    @State var item: Item
    var canEditEmojis: Bool
    var emojiSize: CGFloat = 15
    var emojiSpacing: CGFloat?
    
    var body: some View {
        HStack(spacing: emojiSpacing) {
            Text(item.position.description)
            ForEach(0..<Int(item.total), id: \.self) { image in
                let emojiImage = item.name?.ToImage(fontSize: emojiSize)
                Image(uiImage: emojiImage!)
                    .opacity(getItemQuantityWithOffset(quantity: item.quantity) >= Int64(image) ? 1.0 : 0.1)
                    .onTapGesture {
                        item.quantity = setItemQuantityWithOffset(quantity: Int64(image))
                        item.modified = Date()
                        itemStore.saveChanges()
                    }
            }
        }
        .disabled(!canEditEmojis)
    }
}

private func getItemQuantityWithOffset(quantity: Int64) -> Int64 {
    return quantity - 1
}

private func setItemQuantityWithOffset(quantity: Int64) -> Int64 {
    return quantity + 1
}

#Preview {
    ItemRowView(item: PersistenceController.shared.sampleItem, canEditEmojis: true)
}
