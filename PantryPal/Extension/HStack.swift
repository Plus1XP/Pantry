//
//  HStack.swift
//  PantryPal
//
//  Created by nabbit on 15/07/2024.
//

import SwiftUI

extension HStack {
    func withFocusFieldStyle(colorScheme: ColorScheme, focusState: Bool) -> some View {
        self.padding()
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(Color.setFieldBackgroundColor(colorScheme: colorScheme))
            )
            .border(focusState ? colorScheme == .light ? .white : Color(UIColor.secondarySystemBackground) : .clear)
            .cornerRadius(12)
            .shadow(color: focusState ? colorScheme == .light ? .gray.opacity(0.4) : .white.opacity(0.4) : .clear, radius: 2)
    }
}
