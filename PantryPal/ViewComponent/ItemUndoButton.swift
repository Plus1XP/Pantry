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
    @State var pushes: Int = 0

    
    var body: some View {
//        if !self.itemStore.itemCache.isEmpty {
            Button(action: {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                self.itemStore.validateUndoMethod()
            }) {
                Image(systemName: self.itemStore.itemCache.isEmpty ? "arrowshape.turn.up.backward.badge.clock" : "arrowshape.turn.up.backward.badge.clock.fill")
                    .symbolEffect(
                        .bounce.up.byLayer,
                        options: .speed(1).repeat(1),
                        value: self.itemStore.itemCache.isEmpty
                    )
                    .contentTransition(.symbolEffect(.replace))
            }
            .foregroundStyle(self.itemStore.itemCache.isEmpty ? .gray : .blue)
            .disabled(self.itemStore.itemCache.isEmpty)
//            .onAppear(perform: {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    self.animate = true
//                }
//            })
//            .onDisappear(perform: {
//                self.animate = false
//            })
//        }
    }
}

#Preview {
    @State var items: Set<Item> = [PersistenceController.preview.sampleItem]
    
    return ItemUndoButton()
        .environmentObject(ItemStore())
}
