//
//  ItemDebugButtonView.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct ItemDebugButtons: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var itemStore: ItemStore
    @State var canShowAppLogo: Bool = false
    
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
        Button(action: {
            self.canShowAppLogo.toggle()
        }) {
            Label("AppLogo", systemImage: "apps.iphone")
                .foregroundStyle(setFontColor(colorScheme: self.colorScheme), .blue)
        }
        .fullScreenCover(isPresented: $canShowAppLogo, content: {AppLogoView(canShowAppLogo: $canShowAppLogo)})
    }
}

#Preview {
    HStack {
        ItemDebugButtons()
    }
    .environmentObject(ItemStore())
    .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
}
