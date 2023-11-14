//
//  ItemDetailsView.swift
//  Pantry
//
//  Created by nabbit on 09/11/2023.
//

import SwiftUI

struct ItemDetailsView: View {
    @EnvironmentObject var itemStore: ItemStore
    @Environment(\.dismiss) var dismiss
    @State var item: Item
    @Binding var canEditItem: Bool

    var body: some View {
        Form {
            Section(header: EmojiTextField(text: Binding(get: {item.name ?? ""}, set: {item.name = $0}))
                .font(.largeTitle)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .disabled(!self.canEditItem)
                .frame(maxWidth: .infinity, alignment: .center)) {
                
            }
            Section(header: Text("Quantity Remaining").frame(maxWidth: .infinity, alignment: .center)) {
                HStack {
//                                        Text("\(tempItem.quantity.description) / \(tempItem.total.description)")
//                    Spacer()
                    TextField("Quantity", text: Binding(get: {"\(item.quantity)"}, set: {item.quantity = Int64($0) ?? 0}))
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                        .disabled(!self.canEditItem)
                    Text("of")
                    TextField("Total", text: Binding(get: {"\(item.total)"}, set: {item.total = Int64($0) ?? 0}))
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.leading)
                        .disabled(!self.canEditItem)
//                    Spacer()
                }
            }
            Section(header: Text("Notes").frame(maxWidth: .infinity, alignment: .center)) {
                HStack {
                    TextEditor(text: Binding(get: {item.notes ?? ""}, set: {item.notes = $0}))
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                        .disabled(!self.canEditItem)

                }
            }
            Section(header: Text("Last Modified").frame(maxWidth: .infinity, alignment: .center)) {
                HStack {
                    Text(item.modified!, formatter: itemFormatter)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            if canEditItem {
                HStack{
                    Spacer()
                    Button("Save", systemImage: "plus.circle", action: {
                        item.modified = Date()
                        itemStore.saveChanges()
                        self.canEditItem = false
                        dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    Spacer()
                    Button("Cancel", systemImage: "xmark.circle", action: {
                        itemStore.discardChanges()
                        self.canEditItem = false
                        dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    Spacer()
                }
                .foregroundStyle(.white, .white)
                .listRowBackground(Color.clear)
                .disabled(!self.canEditItem)
            }
            
        }
        .onDisappear(perform:
        {
            self.canEditItem = false
        })
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ItemDetailsView(item: PersistenceController.shared.sampleItem, canEditItem: .constant(false))
}
