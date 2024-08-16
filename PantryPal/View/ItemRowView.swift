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
    
    var body: some View {
        VStack {
            EmojiTouchComponent(item: $item, imageLowerRange: 0, imageHigherRange: 9)
            EmojiTouchComponent(item: $item, imageLowerRange: 10, imageHigherRange: 19)
        }
    }
}

#Preview {
    ItemRowView(item: PersistenceController.shared.sampleItem)
        .environmentObject(ItemStore())
}
