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
    @State private var name: String = "" {
        didSet {
            self.canSaveChanges = self.hasAnyItemValueChanged()
        }
    }
    @State private var quantity: Int64 = 0 {
        didSet {
            self.canSaveChanges = self.hasAnyItemValueChanged()
        }
    }
    @State private var total: Int64 = 0 {
        didSet {
            self.canSaveChanges = self.hasAnyItemValueChanged()
        }
    }
    @State private var bulkPrice: Double = 0 {
        didSet {
            self.canSaveChanges = self.hasAnyItemValueChanged()
        }
    }
    @State private var unitPrice: Double = 0 {
        didSet {
            self.canSaveChanges = self.hasAnyItemValueChanged()
        }
    }
    @State private var note: String = "" {
        didSet {
            self.canSaveChanges = self.hasAnyItemValueChanged()
        }
    }
    @State private var minusAnimation: Bool = false
    @State private var plusAnimation: Bool = false
    @State private var clearAnimation: Bool = false
    @State private var saveAnimation: Bool = false
    @State private var canSaveChanges: Bool = false
    @State private var canHideNamePlaceholderField: Bool = false
    @State private var canHideQuantityField: Bool = false
    @State private var canHidePriceField: Bool = false
    @State private var canHideLastModifiedField: Bool = false
    @Binding var isHideKeyboardButtonAcitve: Bool
    @Binding var canResetFocusState: Bool
    @FocusState private var isPlaceholderFieldFocus: Bool
    @FocusState private var isNameFieldFocus: Bool
    @FocusState private var isQuantityFieldFocus: Bool
    @FocusState private var isTotalFieldFocus: Bool
    @FocusState private var isBulkPriceFieldFocus: Bool
    @FocusState private var isUnitPriceFieldFocus: Bool
    @FocusState private var isNoteFocused: Bool
    var item: Item
    private let sectionTitleColor: Color = Color.secondary
    private let bigScale: CGFloat = 1.1
    private let normalScale: CGFloat = 1
    private let smallScale: CGFloat = 0.9
    
    var body: some View {
        VStack {
            //MARK: Item Name
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    EmojiPicker(emoji: Binding(get: {String(name.onlyEmoji().prefix(1))}, set: {name = $0}), placeholder: "Untitled Item", emojiAlignment: .center, fontSize: 50)
                        .fixedSize(horizontal: true, vertical: true)
                        .focused($isNameFieldFocus)
                        .onChange(of: self.isNameFieldFocus, {
                            self.hideFieldsOnFocusChange(focusState: self.isNameFieldFocus)
                        })
                        .scaleEffect(isNameFieldFocus ? bigScale: normalScale)
            })
            .padding(.bottom, isAnyFieldFocused() ? 0 : nil)
            
            //MARK: Item Quantity
            if !self.canHideQuantityField {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text("Quantity Remaining")
                        .font(.footnote)
                        .textCase(nil)
                        .foregroundStyle(self.sectionTitleColor)
                })

                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    if self.isQuantityFieldFocus || self.isTotalFieldFocus {
                        VStack(alignment: .center, content: {
                            Button(action: {
                                self.minusAnimation.toggle()
                                if self.isQuantityFieldFocus && self.quantity > 0 {
                                    self.quantity -= 1
                                }
                                else if self.isTotalFieldFocus && self.total > 0 {
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
                        })
                    }
                    
                    VStack {
                        HStack {
                            TextField("Quantity", text: Binding(get: {"\(self.quantity)"}, set: {self.quantity = Int64($0) ?? 0}), prompt: Text("Current"))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($isQuantityFieldFocus)
                                .onChange(of: self.isQuantityFieldFocus, {
                                    self.hideFieldsOnFocusChange(focusState: self.isQuantityFieldFocus)
                                })
                            Text("of")
                            TextField("Total", text: Binding(get: {"\(self.total)"}, set: {self.total = Int64($0) ?? 0}), prompt: Text("Total"))
                                .multilineTextAlignment(.leading)
                                .keyboardType(.numberPad)
                                .focused($isTotalFieldFocus)
                                .onChange(of: self.isTotalFieldFocus, {
                                    self.hideFieldsOnFocusChange(focusState: self.isTotalFieldFocus)
                                })
                        }
                        .padding()
                        .foregroundColor(.primary)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme))
                        )
                        
                        .border(isQuantityFieldFocus || isTotalFieldFocus ? colorScheme == .light ? .white : Color(UIColor.secondarySystemBackground) : .clear)
                        .cornerRadius(12)
                        .shadow(color: isQuantityFieldFocus || isTotalFieldFocus ? colorScheme == .light ? .gray.opacity(0.4) : .white.opacity(0.4) : .clear, radius: 2)
                    }
                    
                    if self.isQuantityFieldFocus || self.isTotalFieldFocus {
                        VStack(alignment: .center, content: {
                            Button(action: {
                                self.plusAnimation.toggle()
                                if self.isQuantityFieldFocus {
                                    if self.quantity == self.total {
                                        self.quantity += 1
                                        self.total += 1
                                    } else {
                                        self.quantity += 1
                                    }
                                }
                                else if self.isTotalFieldFocus {
                                    self.total += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .symbolEffect(.bounce, options: .speed(2), value: self.plusAnimation)
                                    .font(.title)
                            }
                            .padding()
                            .foregroundStyle(.white, .blue)
                        })
                    }
                })
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom, isAnyFieldFocused() ? 0 : nil)
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
                                      format: .currency(code: locale.currency?.identifier ?? "USD"))
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .focused($isBulkPriceFieldFocus)
                            .onChange(of: self.isBulkPriceFieldFocus, {
                                self.hideFieldsOnFocusChange(focusState: self.isBulkPriceFieldFocus)
                            })
                        }
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
                        
                        .border(isBulkPriceFieldFocus ? colorScheme == .light ? .white : Color(UIColor.secondarySystemBackground) : .clear)
                        .cornerRadius(12)
                        .shadow(color: isBulkPriceFieldFocus ? colorScheme == .light ? .gray.opacity(0.4) : .white.opacity(0.4) : .clear, radius: 2)
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
                                      format: .currency(code: locale.currency?.identifier ?? "USD"))
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .focused($isUnitPriceFieldFocus)
                            .onChange(of: self.isUnitPriceFieldFocus, {
                                self.hideFieldsOnFocusChange(focusState: self.isUnitPriceFieldFocus)
                            })
                        }
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
                        
                        .border(isUnitPriceFieldFocus ? colorScheme == .light ? .white : Color(UIColor.secondarySystemBackground) : .clear)
                        .cornerRadius(12)
                        .shadow(color: isUnitPriceFieldFocus ? colorScheme == .light ? .gray.opacity(0.4) : .white.opacity(0.4) : .clear, radius: 2)
                    }
                }
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom, isAnyFieldFocused() ? 0 : nil)
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
                    TextEditor(text: Binding(get: {note}, set: {note = $0}))
                        .scrollContentBackground(.hidden) // <- Hide it
                        .background(.clear) // To see this
                        .focused($isNoteFocused)
                        .onChange(of: self.isNoteFocused, {
                            self.hideFieldsOnFocusChange(focusState: self.isNoteFocused)
                        })
                if !self.isNoteFocused && note == "" {
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
                .fill(Color.setFieldBackgroundColor(colorScheme: self.colorScheme))
            )
            .border(isNoteFocused ? colorScheme == .light ? .white : Color(UIColor.secondarySystemBackground) : .clear)
            .cornerRadius(12)
            .shadow(color: isNoteFocused ? colorScheme == .light ? .gray.opacity(0.4) : .white.opacity(0.4) : .clear, radius: 2)
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            //MARK: Item Lst Modified
            if !self.canHideLastModifiedField {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text("Last Modified")
                        .font(.footnote)
                        .textCase(nil)
                        .foregroundStyle(self.sectionTitleColor)
                })
                
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text(item.modified ?? Date.distantFuture, formatter: Formatter.dateFormatter)
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
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
            }
            
            //MARK: Item Save Changes
            if self.canSaveChanges {
                HStack {
                    Spacer()
                    Button(action: {
                        self.clearAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.clearAnimation = false
                            self.name = self.item.name ?? ""
                            self.quantity = self.item.quantity
                            self.total = self.item.total
                            self.bulkPrice = self.item.bulkprice
                            self.unitPrice = self.item.unitprice
                            self.note = self.item.note ?? ""
                            self.itemStore.discardChanges()
                            self.canSaveChanges = false
                            self.resetFocusState()
                        }
                    }, label: {
                        Image(systemName: self.clearAnimation ? "xmark.circle" : "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                            .symbolEffect(.bounce, options: .speed(2), value: self.clearAnimation)
                            .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: self.clearAnimation)
                            .contentTransition(.symbolEffect(.replace))
                            .background(
                                Circle()
                                    .fill(Color.setFieldBackgroundColor(colorScheme: colorScheme).opacity(1))
                                    .cornerRadius(25.0)
                            )
                    })
                    Spacer()
                    Button(action: {
                        self.saveAnimation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.saveAnimation = false
                            self.item.name = name
                            self.item.quantity = quantity
                            self.item.total = total
                            self.item.bulkprice = bulkPrice
                            self.item.unitprice = unitPrice
                            self.item.note = note
                            self.item.modified = Date()
                            self.itemStore.saveChanges()
                            self.canSaveChanges = false
                            self.dismiss()
                        }
                    }, label: {
                        Image(systemName: self.saveAnimation ? "checkmark.circle" : "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)
                            .symbolEffect(.bounce, options: .speed(2), value: self.saveAnimation)
                            .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: self.saveAnimation)
                            .contentTransition(.symbolEffect(.replace))
                            .background(
                                Circle()
                                    .fill(Color.setFieldBackgroundColor(colorScheme: colorScheme).opacity(1))
                                    .cornerRadius(25.0)
                            )
                    })
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
                .disabled(!self.canSaveChanges)
            }
        }
        .onAppear(perform: {
            self.name = self.item.name ?? ""
            self.quantity = self.item.quantity
            self.total = self.item.total
            self.bulkPrice = self.item.bulkprice
            self.unitPrice = self.item.unitprice
            self.note = self.item.note ?? ""
        })
        .onChange(of: self.canResetFocusState, {
            self.resetFocusState()
        })
        .background(Color.setViewBackgroundColor(colorScheme: self.colorScheme))
    }
    
    //MARK: Item Functions
    private func hasAnyItemValueChanged() -> Bool {
        if name != item.name || quantity != item.quantity || total != item.total || bulkPrice != item.bulkprice || unitPrice != item.unitprice || note != item.note {
            return true
        } else {
            return false
        }
    }
    
    private func isAnyFieldFocused() -> Bool {
        if isNameFieldFocus == true || isQuantityFieldFocus == true  || isTotalFieldFocus == true || isBulkPriceFieldFocus == true || isUnitPriceFieldFocus == true || isNoteFocused == true {
            return true
        } else {
            return false
        }
    }
    
    private func hideFieldsOnFocusChange(focusState: Bool) -> Void {
        if focusState {
            // Delay allows else statement to evaluate and fire
            // first in sync before next Fields if statement
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.canHideLastModifiedField = true
                self.isHideKeyboardButtonAcitve = true
//                if focusState == self.isNoteFocused {
//                    self.canHideQuantityField = true
//                    self.canHidePriceField = true
//                }
            }
        } else {
            self.canHideLastModifiedField = false
            self.isHideKeyboardButtonAcitve = false
//            if focusState == self.isNoteFocused {
//                self.canHideQuantityField = false
//                self.canHidePriceField = false
//            }
        }
    }
    
    private func resetFocusState() -> Void {
        self.isNameFieldFocus = false
        self.isQuantityFieldFocus = false
        self.isTotalFieldFocus = false
        self.isBulkPriceFieldFocus = false
        self.isUnitPriceFieldFocus = false
        self.isNoteFocused = false
    }
}

#Preview {
    ItemDetailsView(isHideKeyboardButtonAcitve: .constant(false), canResetFocusState: .constant(false), item: PersistenceController.shared.sampleItem)
        .environmentObject(ItemStore())
        .preferredColorScheme(.light)
}

#Preview {
    ItemDetailsView(isHideKeyboardButtonAcitve: .constant(false), canResetFocusState: .constant(false), item: PersistenceController.shared.sampleItem)
        .environmentObject(ItemStore())
        .preferredColorScheme(.dark)
}
