//
//  CancelButtonStyle.swift
//  PantryPal
//
//  Created by nabbit on 15/07/2024.
//

import SwiftUI

struct CancelButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var clearAnimation: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .foregroundStyle(.red)
            .symbolEffect(.bounce, options: .speed(2), value: self.clearAnimation)
            .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: self.clearAnimation)
            .contentTransition(.symbolEffect(.replace))
            .background(
                Circle()
                    .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme).opacity(1))
                    .cornerRadius(25.0)
            )
    }
}
