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
    var isFocus: ItemField?
    
    var body: some View {
        Button(action: {
            self.plusAnimation.toggle()
            if self.isFocus == .quantity {
                if self.quantity == self.total {
                    self.quantity += 1
                    self.total += 1
                } else {
                    self.quantity += 1
                }
            }
            else if self.isFocus == .total {
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
    }
}

#Preview {
    PlusButtonComponent(quantity: .constant(0), total: .constant(0), isFocus: ItemField.quantity)
}
