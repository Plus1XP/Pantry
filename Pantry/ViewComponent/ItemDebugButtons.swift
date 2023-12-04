//
//  ItemDebugButtonView.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct ItemDebugButtons: View {
    @EnvironmentObject var itemStore: ItemStore
    
    var body: some View {
        Button(action: {
            self.itemStore.sampleItems()
        }) {
            Label("Mock Data", systemImage: "plus.circle.fill")
                .foregroundStyle(.white, .green)
        }
        Button(action: {
            self.itemStore.deleteAll()
        }) {
            Label("Mock Data", systemImage: "minus.circle.fill")
                .foregroundStyle(.white, .red)
        }
    }
}

#Preview {
    HStack {
        ItemDebugButtons()
    }
    .environmentObject(ItemStore())
    .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
}
