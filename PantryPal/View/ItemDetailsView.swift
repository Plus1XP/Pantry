//
//  ItemDetailsView.swift
//  Pantry
//
//  Created by nabbit on 09/11/2023.
//

import SwiftUI
import Combine

struct ItemDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var itemStore: ItemStore
    @State private var name: String = ""
    @State private var quantity: Int64 = 0 {
        didSet {
            if quantity > itemStore.maxItemQuantity {
                quantity = itemStore.maxItemQuantity
                confirmMaximumItemsAlert = true
            }
            if quantity > total {
                total = quantity
            }
        }
    }
    @State private var total: Int64 = 0 {
        didSet {
            if total > itemStore.maxItemQuantity {
                total = itemStore.maxItemQuantity
                confirmMaximumItemsAlert = true
            }
        }
    }
    @State private var bulkPrice: Double = 0
    @State private var unitPrice: Double = 0
    @State private var note: String = ""
    @State private var cancelAnimation: Bool = false
    @State private var saveAnimation: Bool = false
    @State private var canSaveChanges: Bool = false
    @State private var canHideNamePlaceholderField: Bool = false
    @State private var canHideQuantityField: Bool = false
    @State private var canHidePriceField: Bool = false
    @State private var canHideLastModifiedField: Bool = false
    @State private var confirmMaximumItemsAlert: Bool = false
    @Binding var isHideKeyboardButtonAcitve: Bool
    @FocusState private var isFocus: ItemField?
    var item: Item
    private let sectionTitleColor: Color = Color.secondary
    private let bigScale: CGFloat = 1.1
    private let normalScale: CGFloat = 1
    private let smallScale: CGFloat = 0.9
    
    var body: some View {
        VStack {
            //MARK: Item Name
            if !self.canHideNamePlaceholderField {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    EmojiPicker(emoji: Binding(get: {String(self.name)}, set: {self.name = String($0.onlyEmoji().prefix(1))}), placeholder: "Untitled Item", emojiAlignment: .center, fontSize: 50)
                        .fixedSize(horizontal: true, vertical: true)
                        .focused($isFocus, equals: .name)
                        .scaleEffect(self.isFocus == .name ? self.bigScale: self.normalScale)
                })
                .padding(.bottom, (self.isFocus != nil) ? 0 : nil)
            }
            
            //MARK: Item Quantity
            if !self.canHideQuantityField {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text("Quantity Remaining")
                        .font(.footnote)
                        .textCase(nil)
                        .foregroundStyle(self.sectionTitleColor)
                })
                
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    if self.isFocus == .quantity || self.isFocus == .total {
                        VStack(alignment: .center, content: {
                            MinusButtonComponent(quantity: $quantity, total: $total, minimumCount: self.itemStore.minItemQuantity, isFocus: self.isFocus)
                        })
                    }
                    
                    VStack {
                        HStack {
                            TextField("Quantity", text: Binding(get: {"\(self.quantity)"}, set: {self.quantity = Int64($0) ?? 0}), prompt: Text("Current"))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($isFocus, equals: .quantity)
                            Text("of")
                            TextField("Total", text: Binding(get: {"\(self.total)"}, set: {self.total = Int64($0) ?? 0}), prompt: Text("Total"))
                                .multilineTextAlignment(.leading)
                                .keyboardType(.numberPad)
                                .focused($isFocus, equals: .total)
                        }
                        .withFocusFieldStyle(colorScheme: self.colorScheme, focusState: self.isFocus == .quantity || self.isFocus == .total)
                    }
                    
                    if self.isFocus == .quantity || self.isFocus == .total {
                        VStack(alignment: .center, content: {
                            PlusButtonComponent(quantity: $quantity, total: $total, maximumCount: self.itemStore.maxItemQuantity, isFocus: self.isFocus)
                        })
                    }
                })
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom, (self.isFocus != nil) ? 0 : nil)
            }
            
            //MARK: Item Price
            if !self.canHidePriceField {
                HStack {
                    VStack {
                        HStack {
                            Text("Price/Bulk")
                                .font(.footnote)
                                .textCase(nil)
                                .foregroundStyle(self.sectionTitleColor)
                        }
                        HStack {
                            TextField("Amount", value: Binding(get: { self.bulkPrice }, set: { self.bulkPrice = $0 }),
                                      format: .currency(code: self.locale.currency?.identifier ?? "USD"))
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .focused($isFocus, equals: .bulkPrice)
                        }
                        .withFocusFieldStyle(colorScheme: self.colorScheme, focusState: self.isFocus == .bulkPrice)
                    }
                    
                    VStack {
                        HStack {
                            Text("Price/Unit")
                                .font(.footnote)
                                .textCase(nil)
                                .foregroundStyle(self.sectionTitleColor)
                        }
                        HStack {
                            TextField("Amount", value: Binding(get: { self.unitPrice }, set: { self.unitPrice = $0 }),
                                      format: .currency(code: self.locale.currency?.identifier ?? "USD"))
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .focused($isFocus, equals: .unitPrice)
                        }
                        .withFocusFieldStyle(colorScheme: self.colorScheme, focusState: self.isFocus == .unitPrice)
                    }
                }
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom, (self.isFocus != nil) ? 0 : nil)
            }
            
            //MARK: Item Notes
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                Text("Notes")
                    .font(.footnote)
                    .textCase(nil)
                    .foregroundStyle(self.sectionTitleColor)
            })
            
            // TextEditor does not have a placeholder Using a
            // ZStack & FocusState as a work around.
            ZStack(alignment: .topLeading, content: {
                TextEditor(text: Binding(get: {self.note}, set: {self.note = $0}))
                    .scrollContentBackground(.hidden) // <- Hide it
                    .background(.clear) // To see this
                    .focused($isFocus, equals: .note)
                    .onChange(of: self.isFocus, {
                        if self.isFocus == .note {
                            withAnimation(.bouncy) {
//                                canHideNamePlaceholderField = true
                                canHideQuantityField = true
                                canHidePriceField = true
                            }
                        } else {
                            withAnimation(.bouncy) {
//                                canHideNamePlaceholderField = false
                                canHideQuantityField = false
                                canHidePriceField = false
                            }
                        }
                    })
                
                if (self.isFocus != .note ) && self.note == "" {
                    Text("No additional text")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .multilineTextAlignment(.leading)
                        .allowsHitTesting(false)
                }
            })
            .withFocusFieldStyle(colorScheme: self.colorScheme, focusState: self.isFocus == .note)
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom, (self.isFocus != nil) ? 0 : nil)

            //MARK: Item Last Modified
            if !self.isHideKeyboardButtonAcitve {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text("Last Modified")
                        .font(.footnote)
                        .textCase(nil)
                        .foregroundStyle(self.sectionTitleColor)
                })
                HStack {
                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                        if let date = self.item.modified {
                            Text(date, formatter: Formatter.dateFormatter)
                        }
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                        .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme))
                    )
                    HStack {
                        DeleteItemDetailsButton(item: item)
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color.setFieldBackgroundColor(colorScheme: colorScheme).opacity(1))
                            .cornerRadius(10.0)
                    )
                }
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
            }
            
            //MARK: Item Save Changes
            if self.canSaveChanges {
                HStack {
                    Spacer()
                    Button(action: {
                        self.cancelAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.cancelAnimation = false
                            self.loadItemFromStore()
                            self.canSaveChanges = false
                            self.isHideKeyboardButtonAcitve = false
                            self.hideKeyboard()
                        }
                    }, label: {
                        Image(systemName: self.cancelAnimation ? "xmark.circle" : "xmark.circle.fill")
                    })
                    .buttonStyle(CancelButtonStyle(cancelAnimation: self.cancelAnimation))
                    Spacer()
                    Button(action: {
                        self.saveAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.saveAnimation = false
                            self.saveItemToStore()
                            self.canSaveChanges = false
                            self.dismiss()
                        }
                    }, label: {
                        Image(systemName: self.saveAnimation ? "checkmark.circle" : "checkmark.circle.fill")
                    })
                    .buttonStyle(SaveButtonStyle(saveAnimation: self.saveAnimation))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom, (self.isFocus != nil) ? 5 : nil)
                .disabled(!self.canSaveChanges)
            }
        }
        .onAppear(perform: {
            self.loadItemFromStore()
        })
        .onChange(of: self.isFocus, {
            // Added else as selecting an emoji is set to 1 character,
            // This hides the keyboard while the button is active.
            if (self.isFocus != nil) {
                self.isHideKeyboardButtonAcitve = true
            } else {
                self.isHideKeyboardButtonAcitve = false
            }
        })
        .onChange(of: self.isHideKeyboardButtonAcitve, {
            if !self.isHideKeyboardButtonAcitve {
                self.hideKeyboard()
            }
        })
        .onChange(of: self.hasAnyItemValueChanged(), {
            withAnimation(.bouncy, {
                self.canSaveChanges = self.hasAnyItemValueChanged()
            })
        })
        .toast(message: "Maximum number of items reached. (20)",
                     isShowing: $confirmMaximumItemsAlert,
                     duration: Toast.short)
        .background(Color.setViewBackgroundColor(colorScheme: self.colorScheme))
    }
    
    //MARK: Item Functions
    private func hasAnyItemValueChanged() -> Bool {
        if self.name != self.item.name || self.quantity != self.item.quantity || self.total != self.item.total || self.bulkPrice != self.item.bulkprice || self.unitPrice != self.item.unitprice || self.note != self.item.note {
            return true
        } else {
            return false
        }
    }
    
    private func loadItemFromStore() -> Void {
        self.name = self.item.name ?? ""
        self.quantity = self.item.quantity
        self.total = self.item.total
        self.bulkPrice = self.item.bulkprice
        self.unitPrice = self.item.unitprice
        self.note = self.item.note ?? ""
        self.itemStore.discardChanges()
    }
    
    private func saveItemToStore() -> Void {
        self.item.name = self.name
        self.item.quantity = self.quantity
        self.item.total = self.total
        self.item.bulkprice = self.bulkPrice
        self.item.unitprice = self.unitPrice
        self.item.note = self.note
        self.item.modified = Date()
        self.itemStore.saveChanges()
    }
}

#Preview {
    ItemDetailsView(isHideKeyboardButtonAcitve: .constant(false), item: PersistenceController.shared.sampleItem)
        .environmentObject(ItemStore())
        .preferredColorScheme(.light)
}

#Preview {
    ItemDetailsView(isHideKeyboardButtonAcitve: .constant(false), item: PersistenceController.shared.sampleItem)
        .environmentObject(ItemStore())
        .preferredColorScheme(.dark)
}
