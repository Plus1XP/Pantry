//
//  ItemDetailsView.swift
//  Pantry
//
//  Created by nabbit on 09/11/2023.
//

import SwiftUI

struct ItemDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var itemStore: ItemStore
    @State var amount: Int64 = 0
    @State var minusAnimation: Bool = false
    @State var plusAnimation: Bool = false
    @Binding var canEditItem: Bool
    @FocusState private var isNoteFocused: Bool
    var item: Item
    private let sectionTitleColor: Color = Color.secondary

    var body: some View {
        VStack {
            //FIXME: EmojionField icon size
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                if self.canEditItem {
                    EmojiTextField(text: Binding(get: {item.name ?? ""}, set: {item.name = $0}), placeholder: "Untitled Item")
                        .fixedSize(horizontal: true, vertical: true)
                } else {
                    Text(item.name ?? "")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 50))
                        .multilineTextAlignment(.center)
                }
            })
            .padding(.bottom)
            
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                Text("Quantity Remaining")
                    .font(.footnote)
                    .textCase(nil)
                    .foregroundStyle(self.sectionTitleColor)
            })
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                if self.canEditItem {
                    VStack(alignment: .center, content: {
                        Button(action: {
                            if self.amount > 0 {
                                self.minusAnimation.toggle()
                                self.amount -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .symbolEffect(.bounce, options: .speed(2), value: self.minusAnimation)
                        }
                        .padding()
                        .foregroundColor(.blue)
                    })
                    .disabled(!self.canEditItem || self.amount == 0)
                }
                VStack {
                    HStack {
                        TextField("Quantity", text: Binding(get: {"\(self.amount)"}, set: {self.amount = Int64($0) ?? 0}), prompt: Text("Current"))
                            .multilineTextAlignment(.trailing)
                            .disabled(!self.canEditItem)
                        Text("of")
                        TextField("Total", text: Binding(get: {"\(item.total)"}, set: {item.total = Int64($0) ?? 0}), prompt: Text("Total"))
                            .multilineTextAlignment(.leading)
                            .disabled(!self.canEditItem)
                    }
                    .padding()
                    .foregroundColor(.primary)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                        .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
                    )
                }
                if self.canEditItem {
                    VStack(alignment: .center, content: {
                        Button(action: {
                            if self.amount < item.total {
                                self.plusAnimation.toggle()
                                self.amount += 1
                            }
                            
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .symbolEffect(.bounce, options: .speed(2), value: self.plusAnimation)
                        }
                        .padding()
                        .foregroundColor(.blue)
                    })
                    .disabled(!self.canEditItem || self.amount == self.item.total)
                }
            })
            .frame(maxWidth: .infinity)
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            HStack {
                VStack {
                    HStack {
                        Text("Price/Bulk")
                            .font(.footnote)
                            .textCase(nil)
                            .foregroundStyle(self.sectionTitleColor)
                    }
                    HStack {
                        TextField("Amount", value: Binding(get: { item.bulkprice }, set: { item.bulkprice = $0 }),
                                  format: .currency(code: locale.currency?.identifier ?? "USD"))
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .disabled(!self.canEditItem)

                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                        .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
                    )
                }
                VStack {
                    HStack {
                        Text("Price/Unit")
                            .font(.footnote)
                            .textCase(nil)
                            .foregroundStyle(self.sectionTitleColor)
                    }
                    HStack {
                        TextField("Amount", value: Binding(get: { item.unitprice }, set: { item.unitprice = $0 }),
                                  format: .currency(code: locale.currency?.identifier ?? "USD"))
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .disabled(!self.canEditItem)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                        .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
                    )
                }
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                Text("Notes")
                    .font(.footnote)
                    .textCase(nil)
                    .foregroundStyle(self.sectionTitleColor)
            })
            
            // TextEditor does not have a placeholder Using a
            // ZStack & FocusState as a work around.
            ZStack(alignment: .topLeading, content: {
                if self.canEditItem {
                    TextEditor(text: Binding(get: {item.notes ?? ""}, set: {item.notes = $0}))
                        .scrollContentBackground(.hidden) // <- Hide it
                        .background(.clear) // To see this
                        .focused($isNoteFocused)
                } else {
                    ScrollView { // <-- add scroll around Text
                        Text(item.notes ?? "")
                            .lineLimit(nil) // <-- tell Text to use as many lines as it needs (so no truncating)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // <-- tell Text to take the entire space available for ScrollView
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // <-- if needed, tell ScrollView to use the full size of its parent too
                }
                if !self.isNoteFocused && (item.notes == "") {
                    Text("No additional text")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .multilineTextAlignment(.leading)
                        .allowsHitTesting(false)
                }
            })
            .padding()
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
            )
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            if !self.canEditItem {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text("Last Modified")
                        .font(.footnote)
                        .textCase(nil)
                        .foregroundStyle(self.sectionTitleColor)
                })
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text(item.modified!, formatter: Formatter.dateFormatter)
                })
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
                )
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
            }
            
            if self.canEditItem {
                HStack{
                    Spacer()
                    Button("Save", systemImage: "checkmark.circle", action: {
                        self.item.modified = Date()
                        self.itemStore.saveChanges()
                        self.canEditItem = false
                        self.dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.green.opacity(0.9))
                    Spacer()
                    Button("Cancel", systemImage: "xmark.circle", action: {
                        self.itemStore.discardChanges()
                        self.canEditItem = false
                        self.dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.red.opacity(0.9))
                    Spacer()
                }
                .foregroundStyle(.white, .white)
                .disabled(!self.canEditItem)
            }
        }
        .onAppear(perform: {
            self.amount = self.item.quantity
        })
        .onChange(of: self.amount, {
            self.item.quantity = self.amount
        })
        .background(setViewBackgroundColor(colorScheme: self.colorScheme))
    }
}

private func setViewBackgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.secondaryBackground : Color.background
}

private func setFieldBackgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.background : Color.secondaryBackground
}

#Preview {
    ItemDetailsView(canEditItem: .constant(false), item: PersistenceController.shared.sampleItem)
        .environmentObject(ItemStore())
        .preferredColorScheme(.light)
}

#Preview {
    ItemDetailsView(canEditItem: .constant(false), item: PersistenceController.shared.sampleItem)
        .environmentObject(ItemStore())
        .preferredColorScheme(.dark)
}
