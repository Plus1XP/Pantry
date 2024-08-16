//
//  EmojiTouchComponent.swift
//  PantryPal
//
//  Created by nabbit on 16/08/2024.
//

import SwiftUI

struct EmojiTouchComponent: View {
    @EnvironmentObject var itemStore: ItemStore
    @Binding var item: Item
    @State var animate: Bool = false
    var imageLowerRange: Int
    var imageHigherRange: Int
    var emojiSize: CGFloat = 15
    var emojiSpacing: CGFloat?
    
    var body: some View {
        HStack(spacing: self.emojiSpacing) {
            ForEach(0..<Int(self.item.total), id: \.self) { image in
                if image >= self.imageLowerRange && image <= self.imageHigherRange {
                    let emojiImage = self.item.name?.ToImage(fontSize: self.emojiSize)
                    Image(uiImage: emojiImage!)
                        .opacity(getItemQuantityWithOffset(quantity: self.item.quantity) >= Int64(image) ? 1.0 : 0.1)
                        .onTapGesture {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            self.animate.toggle()
                            if !(image == 0 && self.item.quantity == 1) {
                                self.itemStore.updateEntryQuantity(entry: self.item, entryQuantity: setItemQuantityWithOffset(quantity: Int64(image)))
                            } else {
                                self.itemStore.updateEntryQuantity(entry: self.item, entryQuantity: 0)
                            }
                        }
                        .shake($animate) {
                            debugPrint("Execute Shake Animation")
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
    EmojiTouchComponent(item: .constant(PersistenceController.shared.sampleItem), imageLowerRange: 0, imageHigherRange: 4)
        .environmentObject(ItemStore())
}
