//
//  new.swift
//  Pantry
//
//  Created by nabbit on 02/11/2023.
//

import SwiftUI

struct NewItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @State var name: String = ""
    @State var total: Int64 = 0
    @State var bulkPrice: Double = 0.00
    @State var unitPrice: Double = 0.00
    @State var note: String = ""
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add item")
                .font(.title3)
                .padding(.horizontal)
            Divider()
            Group {
                HStack {
                    EmojiPicker(emoji: $name, placeholder: "Pick Emoji", emojiAlignment: .left)
                        .multilineTextAlignment(.leading)
                        .disableAutocorrection(false)
                }
                HStack {
                    TextField("Enter Quantity", value: $total, formatter: Formatter.numberFormatter)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Bulk:")
                    TextField("Bulk price", value: $bulkPrice, formatter: Formatter.currencyFormatter)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Unit:")
                    TextField("Unit price", value: $unitPrice, formatter: Formatter.currencyFormatter)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    // TextEditor does not have a placeholder
                    // Using a ZStack & FocusState as a work around.
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $note)
                            .focused($isNoteFocused)
                            .multilineTextAlignment(.leading)
                            .disableAutocorrection(false)
                        if !isNoteFocused && note.isEmpty {
                            Text("Quick Notes")
                                .multilineTextAlignment(.leading)
                                .disableAutocorrection(false)
                                .foregroundColor(Color(uiColor: .placeholderText))
                                .padding(.top, 10)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
            Divider()
            HStack{
                Spacer()
                Button("Add", systemImage: "plus.circle.fill", action: {
                    itemStore.addNewEntry(name: self.name, quantity: self.total, total: self.total, bulkPrice: self.bulkPrice, unitPrice: self.unitPrice, note: self.note)
                    isNoteFocused = false
                    dismiss()
                })
                .padding(.top)
                .buttonStyle(.borderedProminent)
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    NewItemView()
}
