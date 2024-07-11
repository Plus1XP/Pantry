//
//  ItemUndoButton.swift
//  Pantry
//
//  Created by nabbit on 10/07/2024.
//

import SwiftUI

struct ItemUndoButton: View {
    @EnvironmentObject var itemStore: ItemStore
    @State var animate: Bool = false
    
    var body: some View {
            Button(action: {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                self.itemStore.validateUndoMethod()
//                self.animate.toggle()
            }) {
                Image(systemName: self.itemStore.itemCache.isEmpty ? "arrowshape.turn.up.backward" : "arrowshape.turn.up.backward.badge.clock.fill")
                    .symbolEffect(
                        .bounce.up.byLayer,
                        options: .speed(1).repeat(1),
                        value: self.itemStore.itemCache.isEmpty
                    )
                    .contentTransition(.symbolEffect(.replace))
                    .rotationEffect(.degrees(self.animate ? -360 : 0))
            }
            .foregroundStyle(self.itemStore.itemCache.isEmpty ? .gray : .blue)
            .disabled(self.itemStore.itemCache.isEmpty)
    }
}

#Preview {
    @State var items: Set<Item> = [PersistenceController.preview.sampleItem]
    
    return ItemUndoButton()
        .environmentObject(ItemStore())
}
