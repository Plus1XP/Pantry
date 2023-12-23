//
//  SettingButtonViewComponent.swift
//  Pantry
//
//  Created by nabbit on 04/12/2023.
//

import SwiftUI

struct SettingButton: View {
    @Binding var canPresentSettingsPopOver: Bool
    
    var body: some View {
        Button(action: {
            self.canPresentSettingsPopOver.toggle()
        }) {
            Label("Settings", systemImage: "gear")
                .rotationEffect(.degrees(self.canPresentSettingsPopOver ? 360 : 0))
                .scaleEffect(self.canPresentSettingsPopOver ? 1.5 : 1)
                .animation(.easeInOut, value: self.canPresentSettingsPopOver)
        }
    }
}

#Preview {
    SettingButton(canPresentSettingsPopOver: .constant(false))
}
