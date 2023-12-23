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
    @State var animate: Bool = false
    @State private var scaleFactor: CGFloat = 1
    var emojiSize: CGFloat = 15
    var emojiSpacing: CGFloat?
    
    var body: some View {
        HStack(spacing: emojiSpacing) {
            ForEach(0..<Int(item.total), id: \.self) { image in
                let emojiImage = item.name?.ToImage(fontSize: emojiSize)
                Image(uiImage: emojiImage!)
                    .scaleEffect(self.scaleFactor)
                    .animation(.default)
                    .opacity(getItemQuantityWithOffset(quantity: item.quantity) >= Int64(image) ? 1.0 : 0.1)
                    .onTapGesture {
                        self.scaleFactor = 1.25
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.scaleFactor = 1
                        }
                        if !(image == 0 && item.quantity == 1) {
                            item.quantity = setItemQuantityWithOffset(quantity: Int64(image))
                            item.modified = Date()
                            itemStore.saveChanges()
                        } else {
                            item.quantity = 0
                            item.modified = Date()
                            itemStore.saveChanges()
                        }
                    }
            }
        }
    }
}

private func getItemQuantityWithOffset(quantity: Int64) -> Int64 {
    return quantity - 1
}

private func setItemQuantityWithOffset(quantity: Int64) -> Int64 {
    return quantity + 1
}

#Preview {
    ItemRowView(item: PersistenceController.shared.sampleItem)
}
