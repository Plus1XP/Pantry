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
    var emojiSize: CGFloat = 15
    var emojiSpacing: CGFloat?
    
    var body: some View {
        HStack(spacing: emojiSpacing) {
            ForEach(0..<Int(item.total), id: \.self) { image in
                let emojiImage = item.name?.ToImage(fontSize: emojiSize)
                Image(uiImage: emojiImage!)
                    .opacity(getItemQuantityWithOffset(quantity: item.quantity) >= Int64(image) ? 1.0 : 0.1)
                    .onTapGesture {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        self.animate.toggle()
                        if !(image == 0 && item.quantity == 1) {
                            self.itemStore.updateEntryQuantity(entry: item, entryQuantity: setItemQuantityWithOffset(quantity: Int64(image)))
                        } else {
                            self.itemStore.updateEntryQuantity(entry: item, entryQuantity: 0)
                        }
                    }
                    .shake($animate) {
                        debugPrint("Execute Shake Animation")
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
