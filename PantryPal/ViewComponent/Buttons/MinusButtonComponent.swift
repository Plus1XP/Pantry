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
    var minimumCount: Int64
    var isFocus: ItemField?
    
    var body: some View {
        Button(action: {
            self.minusAnimation.toggle()
            if self.isFocus == .quantity && self.quantity > self.minimumCount {
                self.quantity -= 1
            }
            else if self.isFocus == .total && self.total > self.minimumCount {
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
        .sensoryFeedback(.decrease, trigger: minusAnimation)
        .disabled(canDisableButton(focus: self.isFocus, quantity: self.quantity, total: self.total, count: self.minimumCount))
    }
}

private func canDisableButton(focus: ItemField?, quantity: Int64, total: Int64, count: Int64) -> Bool {
    switch focus {
    case .quantity:
        quantity == count
    case .total:
        total == count
    default:
        false
    }
}

#Preview {
    MinusButtonComponent(quantity: .constant(5), total: .constant(5), minimumCount: 0, isFocus: ItemField.quantity)
}
