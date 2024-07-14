//
//  TextFieldView.swift
//  PantryPal
//
//  Created by nabbit on 15/07/2024.
//

import SwiftUI

struct TextFieldView: View {
    @Binding var title: String
    @Binding var value: Double
    
    var body: some View {
        HStack {
//            TextField(self.title, value: Binding(get: { self.bulkPrice }, set: { self.bulkPrice = $0 }),
//                      format: .currency(code: self.locale.currency?.identifier ?? "USD"))
//            .multilineTextAlignment(.center)
//            .keyboardType(.decimalPad)
//            .focused($isBulkPriceFieldFocus)
//            .onChange(of: self.isBulkPriceFieldFocus, {
//                self.showDismissKeyboardButtonIfTrue(focusState: self.isBulkPriceFieldFocus)
//            })
        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .foregroundColor(.primary)
//        .background(
//            RoundedRectangle(
//                cornerRadius: 12,
//                style: .continuous
//            )
//            .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme))
//        )
        
//        .border(self.isBulkPriceFieldFocus ? self.colorScheme == .light ? .white : Color(UIColor.secondarySystemBackground) : .clear)
//        .cornerRadius(12)
//        .shadow(color: self.isBulkPriceFieldFocus ? self.colorScheme == .light ? .gray.opacity(0.4) : .white.opacity(0.4) : .clear, radius: 2)
    }
}

//#Preview {
//    TextFieldView()
//}
