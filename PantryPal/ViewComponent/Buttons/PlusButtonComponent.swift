//
//  PlusButtonComponent.swift
//  PantryPal
//
//  Created by nabbit on 15/07/2024.
//

import SwiftUI

struct PlusButtonComponent: View {
    @State private var plusAnimation: Bool = false
    @Binding var quantity: Int64
    @Binding var total: Int64
    var maximumCount: Int64
    var isFocus: ItemField?
    
    var body: some View {
        Button(action: {
            self.plusAnimation.toggle()
            if self.isFocus == .quantity && quantity < self.maximumCount {
                if self.quantity == self.total {
                    self.quantity += 1
                    self.total += 1
                } else {
                    self.quantity += 1
                }
            }
            else if self.isFocus == .total && total < self.maximumCount {
                self.total += 1
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .symbolEffect(.bounce, options: .speed(2), value: self.plusAnimation)
                .font(.title)
        }
        .padding()
        .foregroundStyle(.white, .blue)
        .buttonRepeatBehavior(.enabled)
        .sensoryFeedback(.increase, trigger: total)
        .disabled(canDisableButton(focus: self.isFocus, quantity: self.quantity, total: self.total, count: self.maximumCount))
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
    PlusButtonComponent(quantity: .constant(5), total: .constant(5), maximumCount: 20, isFocus: ItemField.quantity)
}
