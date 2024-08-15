//
//  MinusButtonComponent.swift
//  PantryPal
//
//  Created by nabbit on 15/07/2024.
//

import SwiftUI

struct MinusButtonComponent: View {
    @State private var minusAnimation: Bool = false
    @Binding var quantity: Int64
    @Binding var total: Int64
    var isFocus: ItemField?
    
    var body: some View {
        Button(action: {
            self.minusAnimation.toggle()
            if self.isFocus == .quantity && self.quantity > 0 {
                self.quantity -= 1
            }
            else if self.isFocus == .total && self.total > 0 {
                if self.quantity == self.total {
                    self.quantity -= 1
                    self.total -= 1
                } else {
                    self.total -= 1
                }
            }
        }) {
            Image(systemName: "minus.circle.fill")
                .symbolEffect(.bounce, options: .speed(2), value: self.minusAnimation)
                .font(.title)
        }
        .padding()
        .foregroundStyle(.white, .blue)
        .buttonRepeatBehavior(.enabled)
    }
}

#Preview {
    MinusButtonComponent(quantity: .constant(0), total: .constant(0), isFocus: ItemField.quantity)
}
