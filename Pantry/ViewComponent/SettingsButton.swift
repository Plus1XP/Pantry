//
//  SettingButtonViewComponent.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

extension ContentView {
    var SettingsButton: some View {
        Button(action: {
            self.isSettingsPopoverPresented.toggle()
        }) {
            Label("Settings", systemImage: "gear")
        }
    }
    
}
//struct SettingButton: View {
//    @Binding var canPresentSettingsPopOver: Bool
//    
//    var body: some View {
//        Button(action: {
//            self.canPresentSettingsPopOver.toggle()
//        }) {
//            Label("Settings", systemImage: "gear")
//        }
//    }
//}

//#Preview {
//    @State var canPresentSettingsPopOver: Bool = false
//    return HStack {
//        SettingButton(canPresentSettingsPopOver: $canPresentSettingsPopOver)
//    }
//}
//
//struct SettingButtonViewComponent_Previews: PreviewProvider, View {
//    @State var canPresentSettingsPopOver: Bool = false
//
//    static var previews: some View {
//        Self()
//    }
//
//    var body: some View {
//        SettingButton(canPresentSettingsPopOver: $canPresentSettingsPopOver)
//    }
//}
